//
//  LocationServicesDelegateMock.swift
//  WeatherFrameworkTests
//
//  Created by Jean-François Dufour on 2019-06-06.
//  Copyright © 2019 Consultation Massawippi. All rights reserved.
//

import Foundation
@testable import WeatherFramework

class LocationServicesDelegateMock : LocationServicesDelegate {
    var isCityHasBeenUpdated = false
    var isLocationNotAvailable = false
    var errorCode:Int = LocationErrors.NoError
    
    func cityHasBeenUpdated(_ city: City) {
        isCityHasBeenUpdated = true
    }
    
    func getAllCityList() -> [City] {
        NSKeyedUnarchiver.setClass(City.self, forClassName: "weatherlr.City")
        let url = Bundle(for: City.self).url(forResource: "Cities", withExtension: "plist")!
        do {
            let rawdata = try Data(contentsOf: url)
            return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawdata) as! [City]
        } catch {
            print("Unexpected error: \(error).")
            print("Couldn't read cities plist file")
        }
        
        return [City]()
    }
    
    func unknownCity(_ cityName:String) {
        
    }
    
    func notInCanada(_ country:String) {
        
    }
    
    func errorLocating(_ errorCode:Int) {
        self.errorCode = errorCode
    }
    
    func locationNotAvailable() {
        isLocationNotAvailable = true
    }
}
