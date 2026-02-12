# WeatherFramework

A Swift framework for fetching and parsing Canadian weather data from Environment Canada RSS feeds. Provides weather forecasts, current conditions, alerts, city management, location services, and user preferences for iOS and watchOS apps.

Used by the [weatherlr](https://github.com/Drvolks/weatherlr) app.

## Requirements

- iOS 26.0+ / watchOS 26.0+
- Swift 6.2 (Swift 5 language mode)
- Xcode 26+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/Drvolks/WeatherFramework.git", from: "1.0.0")
]
```

## API Reference

### WeatherHelper

Main entry point for fetching weather data. All methods are `static`.

```swift
// Fetch weather with 30-minute cache
let wrapper = WeatherHelper.getWeatherInformations(city)

// Fetch weather bypassing cache
let wrapper = WeatherHelper.getWeatherInformationsNoCache(city)

// Fetch weather from raw XML data
let wrapper = WeatherHelper.getWeatherInformationsNoCache(data, city: city)

// Generate weather from a pre-built RssParser
let wrapper = WeatherHelper.generateWeatherInformation(rssParser, city: city)
```

**Display helpers:**

```swift
// Formatted temperature with Min/Max prefix (e.g. "Max 25°")
let text = WeatherHelper.getWeatherTextWithMinMax(weatherInfo)

// Day label (e.g. "Today", "Monday January 5")
let dayText = WeatherHelper.getWeatherDayWhenText(weatherInfo)

// Last refresh time string (e.g. "Last refresh 2:30 PM")
let refreshText = WeatherHelper.getRefreshTime(wrapper)

// Index adjustment for weather array (0 or 1 depending on whether "now" entry exists)
let adjust = WeatherHelper.getIndexAjust(weatherInformations)

// Date arithmetic
let futureDate = WeatherHelper.addDaystoGivenDate(date, NumberOfDaysToAdd: 3)
```

**Image helpers:**

```swift
// Min/Max arrow image (up/down based on tendency)
let image = WeatherHelper.getMinMaxImage(weatherInfo, header: false)

// Min/Max image name ("up" or "down")
let name = WeatherHelper.getMinMaxImageName(weatherInfo)

// Composite image: temperature text drawn over min/max arrow (for watch complications)
let image = WeatherHelper.textToImageMinMax(weatherInfo)

// Map a WeatherStatus to a substitute that shares the same icon asset
let substitute = WeatherHelper.getImageSubstitute(.aFewFlurries) // returns .lightSnow
```

### WeatherInformationWrapper

Container returned by weather fetch methods. Holds the full forecast, alerts, and cache metadata.

```swift
let wrapper: WeatherInformationWrapper

wrapper.weatherInformations  // [WeatherInformation] - forecast entries (current + multi-day)
wrapper.alerts               // [AlertInformation] - active weather alerts
wrapper.city                 // City? - the city this data belongs to
wrapper.lastRefresh          // Date - when data was fetched
wrapper.initialState         // Bool - true if no data has been loaded yet

wrapper.expired()            // Bool - true if data is older than 30 minutes
wrapper.expiredTooLongAgo()  // Bool - true if data is older than 90 minutes
wrapper.refreshNeeded()      // Bool - true if a new fetch is needed (expired, different city, or initial state)
```

### WeatherInformation

A single weather entry (current conditions or a forecast period).

```swift
let info: WeatherInformation

info.temperature       // Int - temperature in Celsius
info.weatherStatus     // WeatherStatus - condition enum (e.g. .sunny, .snow, .rain)
info.weatherDay        // WeatherDay - .now, .today, .tomorow, .day2 ... .day20
info.tendancy          // Tendency - .maximum, .minimum, .steady, .na
info.summary           // String - raw RSS title
info.detail            // String - cleaned forecast detail text
info.when              // String - time period label (e.g. "Monday", "Tonight")
info.night             // Bool - true for overnight forecasts
info.dateObservation   // String - observation date/time for current conditions

info.image()           // UIImage - weather condition icon (with night variant support)
```

### AlertInformation

A weather alert (warning, watch, advisory, statement).

```swift
let alert: AlertInformation

alert.alertText  // String - alert description
alert.url        // String - link to full alert details
alert.type       // AlertType - .warning, .ended, .none
```

### City

Represents a Canadian city supported by Environment Canada. Conforms to `NSCoding` for persistence.

```swift
let city: City

city.id           // String - Environment Canada site ID (e.g. "qc-147")
city.frenchName   // String - French city name
city.englishName  // String - English city name
city.province     // String - province code (e.g. "qc", "on")
city.radarId      // String - radar station ID
city.latitude     // String - latitude coordinate
city.longitude    // String - longitude coordinate
```

### CityHelper

City search, sorting, and loading utilities. All methods are `static`.

```swift
// Search cities (case-insensitive, diacritics-insensitive)
let results = CityHelper.searchCity("montreal", allCityList: cities)

// Search cities matching prefix
let results = CityHelper.searchCityStartingWith("Mon", allCityList: cities)

// Search returning first match or nil
let city = CityHelper.searchSingleCity("quebec", allCityList: cities)

// Get display name in current language
let name = CityHelper.cityName(city)

// Sort city list alphabetically in current language
let sorted = CityHelper.sortCityList(cities)

// Load all cities from Cities.plist bundle resource
let allCities = CityHelper.loadAllCities()

// Get the "Use Current Location" placeholder city
let currentLocation = CityHelper.getCurrentLocationCity()
```

### PreferenceHelper

User preferences stored in shared `UserDefaults` (app group: `group.com.massawippi.weatherlr`). All methods are `static`.

```swift
// Favorites
PreferenceHelper.addFavorite(city)
PreferenceHelper.removeFavorite(city)
PreferenceHelper.removeFavorites()
let favorites = PreferenceHelper.getFavoriteCities()        // [City] - always includes current location at index 0
PreferenceHelper.switchFavoriteCity(cityId: "qc-147")

// Selected city
PreferenceHelper.saveSelectedCity(city)
let selected = PreferenceHelper.getSelectedCity()           // City
let cityToUse = PreferenceHelper.getCityToUse()             // City - resolves current location to actual city

// Last located city (GPS result)
PreferenceHelper.saveLastLocatedCity(city)
PreferenceHelper.removeLastLocatedCity()

// Language
let lang = PreferenceHelper.getLanguage()                   // Language (.French or .English)
PreferenceHelper.saveLanguage(.French)
let isFr = PreferenceHelper.isFrench()                     // Bool

// Quick actions (iOS home screen shortcuts)
PreferenceHelper.updateQuickActions()

// Version upgrade handling
PreferenceHelper.upgrade()

// Locale helper
let langCode = PreferenceHelper.extractLang("fr-CA")        // "fr"
```

### LocationServices

GPS-based city detection with Canada-only validation. Implements `CLLocationManagerDelegate`.

```swift
let locationServices = LocationServices()
locationServices.delegate = myDelegate  // LocationServicesDelegate

// Start with default CLLocationManager
locationServices.start()

// Start with a custom/mock CLLocationManager
locationServices.start(manager: myManager)

// Trigger city update (GPS if current location, direct if specific city)
locationServices.updateCity(city)

// Re-request location if service is active
locationServices.refreshLocation()

// Check if a city represents "Use Current Location"
let isGPS = LocationServices.isUseCurrentLocation(city)     // static
```

### LocationServicesDelegate

Protocol to receive location events.

```swift
protocol LocationServicesDelegate {
    func cityHasBeenUpdated(_ city: City)       // GPS resolved to a city
    func getAllCityList() -> [City]              // Provide full city list for nearest-city lookup
    func unknownCity(_ cityName: String)         // City not found in list
    func notInCanada(_ country: String)          // User is outside Canada
    func errorLocating(_ errorCode: Int)         // Location error (see LocationErrors)
    func locationNotAvailable()                  // Location services denied/restricted
    func locatingCompleted()                     // Location lookup finished
    func locationSameCity()                      // GPS resolved to same city as before
}
```

### UrlHelper

Builds Environment Canada URLs. All methods are `static`.

```swift
let weatherUrl = UrlHelper.getUrl(city)                     // Weather RSS feed URL
let weatherUrl = UrlHelper.getUrl(city, lang: .French)      // Weather URL in specific language
let radarUrl = UrlHelper.getRadarUrl(city)                  // Radar image URL
```

### Enums

**WeatherStatus** - 170+ weather conditions (e.g. `.sunny`, `.snow`, `.rain`, `.blizzard`, `.freezingRain`, etc.). Covers all conditions reported by Environment Canada in both English and French.

**WeatherDay** - Forecast period: `.now`, `.today`, `.tomorow`, `.day2` through `.day20`, `.na`.

**Tendency** - Temperature trend: `.maximum`, `.minimum`, `.steady`, `.na`.

**Language** - `.French` (`"fr"`) or `.English` (`"en"`).

**AlertType** - `.warning`, `.ended`, `.none`.

**WeatherColor** - Hex color values: `.rain` (`0x1fbfff`), `.defaultColor` (`0x1f4f74`), `.watchRing` (`0x65DA7D`).

### RssParser

Parses Environment Canada RSS/XML feeds into `RssEntry` objects.

```swift
// From URL
if let parser = RssParser(url: feedUrl, language: .English) {
    let entries = parser.parse()  // [RssEntry]
}

// From raw XML data
let parser = RssParser(xmlData: data, language: .French)
let entries = parser.parse()
```

### RssEntryToWeatherInformation

Converts parsed RSS entries into weather models.

```swift
let converter = RssEntryToWeatherInformation(rssEntries: entries)
let forecasts = converter.perform()      // [WeatherInformation]
let alerts = converter.getAlerts()       // [AlertInformation]
```

### ExpiringCache

Internal `NSCache` subclass with automatic time-based expiration (default: 30 minutes). Used by `WeatherHelper` to cache fetched weather data.

```swift
ExpiringCache.instance.setObject(obj, forKey: key)                    // Default 30-min timeout
ExpiringCache.instance.setObject(obj, forKey: key, timeout: 60.0)     // Custom timeout in seconds
ExpiringCache.instance.removeAllObjects()                              // Clear cache
```

### String Extensions

```swift
"My Key".localized()             // Localized string using current language
"My Key".localized(.French)      // Localized string in specific language
"3.14".isDouble                  // true - works with both "." and "," decimal separators
```

### Global Constants

```swift
Global.weatherCacheInMinutes        // 30
Global.expirationInMinutes          // 30
Global.expirationLocationInMinutes  // 60
Global.locationDistance              // 5000.0 (meters)
Global.currentLocationMaxDistance    // 1000000.0 (meters, ~1000 km)
Global.SettingGroup                  // "group.com.massawippi.weatherlr"
Global.currentLocationCityId         // "currentLocation"
```
