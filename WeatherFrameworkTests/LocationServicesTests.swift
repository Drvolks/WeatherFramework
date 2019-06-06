//
//  LocationServicesTests.swift
//  WeatherFrameworkTests
//
//  Created by Jean-François Dufour on 2019-06-06.
//  Copyright © 2019 Consultation Massawippi. All rights reserved.
//

import XCTest
import MapKit
@testable import WeatherFramework

class LocationServicesTests: XCTestCase {
    var locationManager:LocationManagerMock!
    var location:CLLocation!
    var service:LocationServices!
    var delegate:LocationServicesDelegateMock!
    var city:City!
    let cityCount = 844
    let cityCountWithLocation = 831
    
    override func setUp() {
        locationManager = LocationManagerMock();
        delegate = LocationServicesDelegateMock()
        city = City(id:"monreal", frenchName: "frenchName", englishName: "englishName", province: "province", radarId: "radarId", latitude:"45.50884", longitude:"-73.58781")
        location = CLLocation(latitude: 45.50884, longitude: -73.58781)
        
        locationManager.mockLocation = location
        
        service = LocationServices()
        service.delegate = delegate
        service.locationManager = locationManager
        service.locationManagerType = LocationManagerMock.self
        locationManager.delegate = service
        
        let cityInitial = City(id:Global.currentLocationCityId, frenchName: "frenchName", englishName: "englishName", province: "province", radarId: "radarId", latitude:"", longitude:"")
        PreferenceHelper.saveSelectedCity(cityInitial)
        PreferenceHelper.saveLastLocatedCity(cityInitial)
    }
    
    override func tearDown() {
        service = nil
    }
    
    func testStart() {
        service.start(manager:locationManager)
        XCTAssertEqual(kCLLocationAccuracyThreeKilometers, locationManager.desiredAccuracy)
        XCTAssertEqual(Global.locationDistance, locationManager.distanceFilter)
        XCTAssertTrue(service.serviceActive)
    }
    
    func testUpdateCity_UseCurrentLocation() {
        city = City(id:Global.currentLocationCityId, frenchName: "frenchName", englishName: "englishName", province: "province", radarId: "radarId", latitude:"10.0", longitude:"10.0")
        service.updateCity(city)
        XCTAssertTrue(service.serviceActive)
        XCTAssertFalse(delegate.isCityHasBeenUpdated)
    }

    func testUpdateCity_DontUseCurrentLocation() {
        service.updateCity(city)
        XCTAssertFalse(service.serviceActive)
        XCTAssertTrue(delegate.isCityHasBeenUpdated)
    }
    
    func testCityHasBeenUpdated() {
        service.cityHasBeenUpdated(city)
        XCTAssertTrue(delegate.isCityHasBeenUpdated)
    }
    
    func testIsUseCurrentLocation() {
        city = City(id:Global.currentLocationCityId, frenchName: "frenchName", englishName: "englishName", province: "province", radarId: "radarId", latitude:"10.0", longitude:"10.0")
        XCTAssertTrue(LocationServices.isUseCurrentLocation(city))
    }
    
    func testIsUseCurrentLocation_not() {
        XCTAssertFalse(LocationServices.isUseCurrentLocation(city))
    }
    
    func testBuildLocations() {
        XCTAssertNil(service.locations)
        service.buildLocations()
        XCTAssertEqual(cityCountWithLocation, service.locations!.count)
    }
    
    func testBuildLocation() {
        let result = service.buildLocation(city: city)
        XCTAssertEqual(city.id, result.city.id)
        XCTAssertEqual(city.latitude, result.location.coordinate.latitude.description)
        XCTAssertEqual(city.longitude, result.location.coordinate.longitude.description)
    }
    
    func testShouldUseCityForLocation() {
        XCTAssertTrue(service.shouldUseCityForLocation(city: city))
    }
    
    func testShouldUseCityForLocation_empty() {
        city = City(id:Global.currentLocationCityId, frenchName: "frenchName", englishName: "englishName", province: "province", radarId: "radarId", latitude:"", longitude:"10.0")
        XCTAssertFalse(service.shouldUseCityForLocation(city: city))
        
        city = City(id:Global.currentLocationCityId, frenchName: "frenchName", englishName: "englishName", province: "province", radarId: "radarId", latitude:"10.0", longitude:"")
        XCTAssertFalse(service.shouldUseCityForLocation(city: city))
    }
    
    func testShouldUseCityForLocation_char() {
        city = City(id:Global.currentLocationCityId, frenchName: "frenchName", englishName: "englishName", province: "province", radarId: "radarId", latitude:"test", longitude:"10.0")
        XCTAssertFalse(service.shouldUseCityForLocation(city: city))
        
        city = City(id:Global.currentLocationCityId, frenchName: "frenchName", englishName: "englishName", province: "province", radarId: "radarId", latitude:"10.0", longitude:"test")
        XCTAssertFalse(service.shouldUseCityForLocation(city: city))
    }
    
    func testGetAllCityList() {
        XCTAssertNil(service.allCityList)
        let result = service.getAllCityList()
        XCTAssertEqual(cityCount, result.count)
        XCTAssertEqual(cityCount, service.allCityList!.count)
    }
    
    func testGetCurrentLocation() {
        service.getCurrentLocation()
        XCTAssertTrue(locationManager.isRequestLocation)
    }
    
    func testHandleLocationServicesAuthorizationStatus_notDetermined() {
        service.handleLocationServicesAuthorizationStatus(status: CLAuthorizationStatus.notDetermined)
        XCTAssertTrue(locationManager.isRequestWhenInUseAuthorization)
    }
    
    func testHandleLocationServicesAuthorizationStatus_denied() {
        service.handleLocationServicesAuthorizationStatus(status: CLAuthorizationStatus.denied)
        XCTAssertTrue(delegate.isLocationNotAvailable)
        XCTAssertFalse(service.serviceActive)
    }
    
    func testHandleLocationServicesAuthorizationStatus_restricted() {
        service.handleLocationServicesAuthorizationStatus(status: CLAuthorizationStatus.restricted)
        XCTAssertTrue(delegate.isLocationNotAvailable)
        XCTAssertFalse(service.serviceActive)
    }
    
    func testHandleLocationServicesAuthorizationStatus_authorizedWhenInUse() {
        service.handleLocationServicesAuthorizationStatus(status: CLAuthorizationStatus.authorizedWhenInUse)
        XCTAssertTrue(locationManager.isRequestLocation)
    }
    
    func testHandleLocationServicesAuthorizationStatus_authorizedAlways() {
        service.handleLocationServicesAuthorizationStatus(status: CLAuthorizationStatus.authorizedAlways)
        XCTAssertTrue(locationManager.isRequestLocation)
    }
    
    func testDisableLocation() {
        service.disableLocation()
        XCTAssertFalse(service.serviceActive)
        XCTAssertNil(locationManager.delegate)
    }
    
    func testEnableLocation() {
        service.enableLocation()
        XCTAssertTrue(service.serviceActive)
        XCTAssertNotNil(locationManager.delegate)
    }
    
    func testEscalateLocationServiceAuthorization() {
        service.escalateLocationServiceAuthorization()
        XCTAssertTrue(locationManager.isRequestAlwaysAuthorization)
    }
    
    func testEscalateLocationServiceAuthorization_always() {
        LocationManagerMock.status = CLAuthorizationStatus.authorizedAlways
        service.escalateLocationServiceAuthorization()
        XCTAssertFalse(locationManager.isRequestAlwaysAuthorization)
    }
    
    func testRefreshLocation() {
        service.serviceActive = true
        service.refreshLocation()
        XCTAssertTrue(locationManager.isRequestLocation)
    }
    
    func testRefreshLocation_inactif() {
        service.serviceActive = false
        service.refreshLocation()
        XCTAssertFalse(locationManager.isRequestLocation)
    }
    
    func testHandleLocationServicesStateAvailable() {
        service.handleLocationServicesStateAvailable()
        XCTAssertTrue(locationManager.isRequestLocation)
    }
    
    func testDidUpdateLocations() {
        var locations = [CLLocation]()
        locations.append(location)
        
        service.locationManager(locationManager, didUpdateLocations: locations)
        XCTAssertFalse(locationManager.isRequestLocation)
        XCTAssertTrue(delegate.isCityHasBeenUpdated)
    }
    
    func testDidUpdateLocations_errors() {
        locationManager.mockLocation = nil
        
        var locations = [CLLocation]()
        locations.append(location)
        
        service.locationManager(locationManager, didUpdateLocations: locations)
        XCTAssertTrue(locationManager.isRequestLocation)
        XCTAssertFalse(delegate.isCityHasBeenUpdated)
    }
    
    func testGetAdressLocalData() {
        service.getAdressLocalData(location)
        XCTAssertTrue(delegate.isCityHasBeenUpdated)
    }
    
    func testGetAdressLocalData_error() {
        location = CLLocation(latitude: 10.0, longitude: 10.0)
        
        service.getAdressLocalData(location)
        XCTAssertFalse(delegate.isCityHasBeenUpdated)
        XCTAssertEqual(LocationErrors.LocationTooFarOrEmpty, delegate.errorCode)
    }
    
    func testGetClosestLocation() {
        service.buildLocations()
        let result = service.getClosestLocation(location)
        // montreal
        XCTAssertEqual("qc-147", result?.city.id)
    }
    
    func testGetClosestLocation_dorval() {
        service.buildLocations()
        location = CLLocation(latitude: 45.4500, longitude: -73.7500)
        let result = service.getClosestLocation(location)
        // Sainte-Catherine
        XCTAssertEqual("qc-b0", result?.city.id)
    }
    
    func testGetClosestLocation_laval() {
        service.buildLocations()
        location = CLLocation(latitude: 45.612499, longitude: -73.707092)
        let result = service.getClosestLocation(location)
        // Laval
        XCTAssertEqual("qc-76", result?.city.id)
    }
    
    func testGetClosestLocation_too_far() {
        service.buildLocations()
        location = CLLocation(latitude: 10.0, longitude: 10.0)
        let result = service.getClosestLocation(location)
        XCTAssertNil(result)
    }
    
    func testGetAdressAndValidateCanada() {
        service.getAdressAndValidateCanada(location)
    }
    
    func testPerformance_buildLocations() {
        self.measure {
            service.buildLocations()
        }
    }
    
}
