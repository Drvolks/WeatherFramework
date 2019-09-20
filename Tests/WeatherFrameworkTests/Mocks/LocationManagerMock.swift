//
//  MockLocationManager.swift
//  WeatherFrameworkTests
//
//  Created by Jean-François Dufour on 2019-06-06.
//  Copyright © 2019 Consultation Massawippi. All rights reserved.
//

import Foundation
import MapKit

class LocationManagerMock : CLLocationManager {
    var mockLocation: CLLocation?
    var isRequestLocation = false
    var isRequestWhenInUseAuthorization = false
    var isRequestAlwaysAuthorization = false
    static var status = CLAuthorizationStatus.authorizedWhenInUse
    
    override var location: CLLocation? {
        return mockLocation
    }
    
    override init() {
        super.init()
    }
    
    override class func authorizationStatus() -> CLAuthorizationStatus {
        return status
    }
    
    override func requestLocation() {
        isRequestLocation = true
    }
    
    override func requestWhenInUseAuthorization() {
        isRequestWhenInUseAuthorization = true
    }
    
    override func requestAlwaysAuthorization() {
        isRequestAlwaysAuthorization = true
    }
}
