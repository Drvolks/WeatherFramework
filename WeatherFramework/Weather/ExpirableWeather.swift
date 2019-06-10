import Foundation

@PropertyWrapper
struct  ExpirableWeather<WeatherInformationWrapper> {
    let duration:TimeInterval = Global.weatherCacheInMinutes
    var expirationDate = Date()
    private var innerValue:WeatherInformationWrapper? = nil
    
    var value: WeatherInformationWrapper? {
        get { return hasExpired() ? nil : innerValue }
        set {
            self.expirationDate = Date().addingTimeInterval(duration)
            self.innerValue = newValue
        }
    }
    
    init() {}
    
    private func hasExpired() -> Bool {
        return expirationDate < Date()
    }
}