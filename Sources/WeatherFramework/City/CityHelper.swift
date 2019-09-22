//
//  CityHelper.swift
//  weatherlr
//
//  Created by Jean-Francois Dufour on 2016-07-09.
//  Copyright © 2016 Jean-Francois Dufour. All rights reserved.
//

import Foundation

public class CityHelper {
    public static func searchCity(_ searchText: String, allCityList: [City]) -> [City] {
        var newFilteredList = [City]()
        
        for i in 0..<allCityList.count {
            let city = allCityList[i]
            
            let name = cityNameForSearch(city)
            
            let searched = searchText.uppercased().folding(options: .diacriticInsensitive, locale: Locale(identifier: "en"))
            
            if name.contains(searched) {
                newFilteredList.append(city)
            }
        }
        
        return newFilteredList
    }
    
    public static func searchCityStartingWith(_ searchText: String, allCityList: [City]) -> [City] {
        var newFilteredList = [City]()
        
        for i in 0..<allCityList.count {
            let city = allCityList[i]
            
            let name = cityNameForSearch(city)
            
            if name.uppercased().hasPrefix(searchText) {
                newFilteredList.append(city)
            }
        }
        
        return newFilteredList
    }
    
    public static func searchSingleCity(_ searchText: String, allCityList: [City]) -> City? {
        let result = searchCity(searchText, allCityList: allCityList)
        if result.count > 0 {
            return result[0]
        }
        
        return nil
    }
    
    
    public static func cityNameForSearch(_ city: City) -> String {
        var name = city.englishName
        if(PreferenceHelper.isFrench()) {
            name = city.frenchName
        }
        
        name = name.uppercased().folding(options: .diacriticInsensitive, locale: Locale(identifier: "en"))
        
        return name
    }
    
    public static func cityName(_ city:City) -> String {
        var name = city.englishName
        if(PreferenceHelper.isFrench()) {
            name = city.frenchName
        }
        
        return name;
    }
    
    public static func sortCityList(_ cityListToSort: [City]) -> [City] {
        var newCityList = cityListToSort
        
        if PreferenceHelper.isFrench() {
            newCityList.sort(by: { $0.frenchName < $1.frenchName })
        } else {
            newCityList.sort(by: { $0.englishName < $1.englishName })
        }
        
        return newCityList
    }
    
    public static func getCurrentLocationCity() -> City {
        let currentLocation = City()
        currentLocation.englishName = "Use Current Location"
        currentLocation.frenchName = "Utiliser la géolocalisation"
        currentLocation.id = Global.currentLocationCityId
        
        return currentLocation
    }
    
    public static func loadAllCities() -> [City] {
        let url = Bundle.main.url(forResource: "Cities", withExtension: "plist")!
        do {
            let rawdata = try Data(contentsOf: url)
            
            NSKeyedUnarchiver.setClass(City.self, forClassName: "City")
            NSKeyedUnarchiver.setClass(City.self, forClassName: "weatherlr.City")
            return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawdata) as! [City]
        } catch {
            print("Unexpected error: \(error).")
            print("Couldn't read cities plist file")
        }
        
        return [City]()
    }
}
