//
//  FavoriteCityHelper.swift
//  weatherlr
//
//  Created by Jean-Francois Dufour on 2016-04-08.
//  Copyright © 2016 Jean-Francois Dufour. All rights reserved.
//

import Foundation
#if os(iOS)
    import UIKit
#endif

class PreferenceHelper {
    static func addFavorite(_ city: City) {
        var favorites = getFavoriteCities()
        var newFavorites = [City]()
        
        saveSelectedCity(city)
        newFavorites.append(city)
        
        for i in 0..<favorites.count {
            if city.id != favorites[i].id {
                newFavorites.append(favorites[i])
            }
        }
        
        saveFavoriteCities(newFavorites)
        updateQuickActions()
    }
    
    static func updateQuickActions() {
        #if os(iOS)
            var shortcutItems = [UIApplicationShortcutItem]()
            let cities = PreferenceHelper.getFavoriteCities()
            
            var i = 0
            for city in cities {
                let shortcutItem = UIApplicationShortcutItem(type: "City:" + city.id, localizedTitle: CityHelper.cityName(city))
                shortcutItems.append(shortcutItem)
                
                i = i+1
                if(i>3) {
                    break
                }
            }
            
            UIApplication.shared.shortcutItems = shortcutItems
        #endif
    }
    
    static func getFavoriteCities() -> [City] {
        do {
            let savedfavorites = try getFavoriteCitiesWithClassName("City")
            return savedfavorites
        } catch {}
        
        // trying with legacy names
        do {
            let savedfavorites = try getFavoriteCitiesWithClassName("weatherlr.City")
            return savedfavorites
        } catch {}
        
        do {
            let savedfavorites = try getFavoriteCitiesWithClassName("weatherlrFree.City")
            return savedfavorites
        } catch {}
        
        return [City]()
    }
    
    static func getFavoriteCitiesWithClassName(_ className:String) throws -> [City] {
        let defaults = UserDefaults(suiteName: Global.SettingGroup)!
        NSKeyedUnarchiver.setClass(City.self, forClassName: className)
        
        if let unarchivedObject = defaults.object(forKey: Global.favotiteCitiesKey) as? Data {
            do {
                let savedfavorites = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as! [City]
                return savedfavorites
            } catch {
                // will throw error
            }
        }
        
        throw PreferenceHelperError.unarchiveError
    }
    
    static func switchFavoriteCity(cityId: String) {
        let cities = getFavoriteCities()
        
        for city in cities {
            if city.id == cityId {
                addFavorite(city)
                break;
            }
        }
    }
    
    fileprivate static func saveFavoriteCities(_ cities: [City]) {
        let defaults = UserDefaults(suiteName: Global.SettingGroup)!
        NSKeyedArchiver.setClassName("City", for: City.self)
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: cities as NSArray)
        defaults.set(archivedObject, forKey: Global.favotiteCitiesKey)
        defaults.synchronize()
    }
    
    fileprivate static func saveSelectedCity(_ city: City) {
        NSKeyedArchiver.setClassName("City", for: City.self)
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: city)
        let defaults = UserDefaults(suiteName: Global.SettingGroup)!
        defaults.set(archivedObject, forKey: Global.selectedCityKey)
        defaults.synchronize()
    }
    
    static func getSelectedCity() -> City? {
        do {
            let selectedCity = try getSelectedCityWithClassName("City")
            return selectedCity
        } catch {}
        
        // try with legacy names
        do {
            let selectedCity = try getSelectedCityWithClassName("weatherlr.City")
            return selectedCity
        } catch {}
        
        do {
            let selectedCity = try getSelectedCityWithClassName("weatherlrFree.City")
            return selectedCity
        } catch {}
        
        return nil
    }
    
    static func getSelectedCityWithClassName(_ className:String) throws -> City? {
        NSKeyedUnarchiver.setClass(City.self, forClassName: className)
        let defaults = UserDefaults(suiteName: Global.SettingGroup)!
        if let unarchivedObject = defaults.object(forKey: Global.selectedCityKey) as? Data {
            do {
                let selectedCity = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as! City
                
                // for legacy City object < 1.1 release
                if selectedCity.radarId.isEmpty {
                    return refreshCity(selectedCity)
                }
                
                return selectedCity
            } catch {
                // will throw error
            }
        }
        
        throw PreferenceHelperError.unarchiveError
    }
    
    static func refreshCity(_ city:City) -> City {
        let path = Bundle.main.path(forResource: "Cities", ofType: "plist")
        let cities = (NSKeyedUnarchiver.unarchiveObject(withFile: path!) as? [City])!
        
        for i in 0..<cities.count {
            let currentCity = cities[i]
            if currentCity.id == city.id {
                // avoid infinite loop
                saveSelectedCity(currentCity)
                
                removeFavorite(currentCity)
                
                var favorites = getFavoriteCities()
                favorites.append(currentCity)
                saveFavoriteCities(favorites)
                
                // reset selected to current
                saveSelectedCity(currentCity)
                return currentCity
            }
        }
        
        return city
    }
    
    static func removeFavorite(_ city: City) {
        let favorites = getFavoriteCities()
        
        if favorites.count == 0 {
            return
        }
        
        var newFavorites = [City]()
        
        for i in 0..<favorites.count {
            if city.id != favorites[i].id {
                newFavorites.append(favorites[i])
            }
        }
        
        saveFavoriteCities(newFavorites)
        
        if let selectedCity = getSelectedCity() {
            if selectedCity.id == city.id {
                saveSelectedCity(newFavorites[0])
            }
        }
    }
    
    static func removeFavorites() {
        let favorites = getFavoriteCities()
        
        if favorites.count == 0 {
            return
        }
        
        var newFavorites = [City]()
        if let city = getSelectedCity() {
            newFavorites.append(city)
        }
        
        saveFavoriteCities(newFavorites)
    }
    
    static func getLanguage() -> Language {
        let defaults = UserDefaults(suiteName: Global.SettingGroup)!
        if let lang = defaults.object(forKey: Global.languageKey) as? String {
            if let langEnum = Language(rawValue: lang) {
                return langEnum
            }
        } else {
            let preferredLanguage = extractLang(Locale.preferredLanguages[0])
            if let lang = Language(rawValue: preferredLanguage) {
                saveLanguage(lang)
                return lang
            }
        }
         
         return Language.English
    }
    
    static func saveLanguage(_ language: Language) {
        let defaults = UserDefaults(suiteName: Global.SettingGroup)!
        defaults.set(language.rawValue, forKey: Global.languageKey)
        defaults.synchronize()
        
        ExpiringCache.instance.removeAllObjects()
    }
    
    static func isFrench() -> Bool {
        if getLanguage() == Language.French {
            return true
        }
        
        return false
    }
    
    static func extractLang(_ locale:String) -> String {
        if let index = locale.range(of: "-") {
            return String(locale[..<index.lowerBound])
        }
                
        return locale
    }
    
    static func upgrade() {
        let defaults = UserDefaults(suiteName: Global.SettingGroup)!
        var shouldUpdateQuickActions = false
        var previousVersion = Double(0)
        
        if let version = defaults.object(forKey: Global.versionKey) as? Double {
            previousVersion = version
            
            if version < 2.5 {
                shouldUpdateQuickActions = true
            }
        } else {
            shouldUpdateQuickActions = true
        }
        
        if shouldUpdateQuickActions {
            updateQuickActions()
        }
        
        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let currentVersionDouble = Double(currentVersion)
            
            if previousVersion != currentVersionDouble {
                defaults.set(currentVersionDouble, forKey: Global.versionKey)
                defaults.synchronize()
            }
        }
    }
}
