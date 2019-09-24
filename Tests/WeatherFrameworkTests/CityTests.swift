//
//  File.swift
//  
//
//  Created by Jean-François Dufour on 2019-09-24.
//

#if !os(watchOS)
import XCTest
@testable import WeatherFramework

class CityTests: XCTestCase {
    var city:City!
    
    override func setUp() {
        city = City()
        city.englishName = "englishName"
        city.frenchName = "frenchName"
        city.latitude = "45,50884"
        city.longitude = "-73,58781"
    }
    
    override func tearDown() {
        city = nil
    }
    
    func testGpsNumbers() {
        XCTAssertTrue(city.latitude.isDouble)
        XCTAssertTrue(city.longitude.isDouble)
    }
}

#endif
