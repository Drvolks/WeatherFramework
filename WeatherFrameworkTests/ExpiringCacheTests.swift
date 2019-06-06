//
//  ExpiringCacheTests.swift
//  WeatherFrameworkTests
//
//  Created by Jean-François Dufour on 2019-06-06.
//  Copyright © 2019 Consultation Massawippi. All rights reserved.
//

import XCTest
@testable import WeatherFramework

class ExpiringCacheTests: XCTestCase {
    var weatherInformation:WeatherInformationWrapper!
    var cache:ExpiringCache!
    var key:NSString!
    
    override func setUp() {
        weatherInformation = WeatherInformationWrapper()
        cache = ExpiringCache.init()
        key = "key"
    }
    
    override func tearDown() {
        weatherInformation = nil
        cache = nil
        key = nil
    }
    
    func testCache() {
        cache.setObject(weatherInformation, forKey: key)
        XCTAssertNotNil(cache.object(forKey: key))
    }
    
    func testSansCache() {
        XCTAssertNil(cache.object(forKey: key))
    }
    
    func testPerformance() {
        self.measure {
            for i in 1...1000 {
                weatherInformation = WeatherInformationWrapper()
                key = NSString(utf8String: "key\(i)")
                
                cache.setObject(weatherInformation, forKey: key)
                cache.object(forKey: key)
            }
        }
    }
    
}
