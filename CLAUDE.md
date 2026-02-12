# WeatherFramework

## Overview

A Swift framework that provides Canadian weather data by parsing Environment Canada's RSS feeds. Used by the **weatherlr** iOS/watchOS app (located at `../weatherlr`).

## Project Structure

```
Sources/WeatherFramework/
  City/              # City model, city list loading (from Cities.plist), geocoding parser
  Rss/               # RSS feed parsing (RssParser, RssEntry, RssEntryToWeatherInformation)
  Weather/           # Weather models (WeatherInformation, WeatherInformationWrapper, AlertInformation, WeatherEnums)
  ExpiringCache.swift        # NSCache subclass with time-based expiration (30 min default)
  Global.swift               # App-wide constants (cache durations, UserDefaults keys, app group ID)
  LocationServices.swift     # CLLocationManager wrapper, reverse geocoding, Canada-only validation
  LocationServicesDelegate.swift  # Protocol for location event callbacks
  PreferenceHelper.swift     # UserDefaults persistence for favorites, selected city, language
  WeatherHelper.swift        # Main entry point: fetches weather, generates images for complications
  UrlHelper.swift            # Builds Environment Canada URLs for weather and radar
  StringExtension.swift      # String.localized() and String.isDouble helpers
Tests/WeatherFrameworkTests/
  Mocks/             # LocationManagerMock, LocationServicesDelegateMock
  Rss/               # RSS parsing tests with XML test data fixtures
  Resources/         # Test XML files and Cities.plist for tests
```

## Build Configuration

- **Swift tools version:** 6.2 with `swiftLanguageModes: [.v5]` (avoids Swift 6 strict concurrency requirements)
- **Platforms:** iOS 26.0, watchOS 26.0
- **Xcode project:** Swift 6.0, deployment target iOS 26.0
- Both SPM (`Package.swift`) and Xcode project (`WeatherFramework.xcodeproj`) are maintained

## Building and Testing

This is an iOS framework -- it requires the iOS SDK (UIKit, MapKit, CoreLocation).

```bash
# Build via SPM (must target iOS SDK, not macOS)
swift build --sdk $(xcrun --show-sdk-path --sdk iphonesimulator) \
  --triple arm64-apple-ios26.0-simulator

# Tests compile with the same command but must run on an iOS Simulator
swift test --sdk $(xcrun --show-sdk-path --sdk iphonesimulator) \
  --triple arm64-apple-ios26.0-simulator
# Note: swift test will build but fail to execute (iOS binary on macOS).
# Use xcodebuild or run in Xcode to actually execute tests on a simulator.
```

## Key Concepts

- **Data source:** Environment Canada RSS feeds (XML). URLs are built from city IDs via localized strings.
- **Bilingual:** French and English, controlled by `PreferenceHelper.getLanguage()`. Localization uses `String.localized()` extension backed by `.lproj` bundles in the client app.
- **City identification:** Each city has an `id` (Environment Canada site ID), French/English names, province, radar ID, and lat/long coordinates.
- **Current location:** Special city ID `"currentLocation"` triggers GPS-based lookup. Reverse geocodes to verify the user is in Canada, then finds the closest city from the full city list.
- **Caching:** `ExpiringCache` (NSCache subclass) holds weather data for 30 minutes. `WeatherInformationWrapper.expired()` checks staleness.
- **App group:** Data shared between app and extensions via `group.com.massawippi.weatherlr` UserDefaults suite.
- **Persistence:** Cities are archived/unarchived with `NSKeyedArchiver`/`NSKeyedUnarchiver` using `NSCoding`. Class name is explicitly set to `"City"` for cross-target compatibility.

## Known Deprecation Warnings (not yet addressed)

- `CLGeocoder` and its geocoding methods deprecated in iOS 26.0 (replacement: MapKit's `MKGeocodingRequest` / `MKReverseGeocodingRequest`)
- `NSKeyedUnarchiver.unarchiveTopLevelObjectWithData` deprecated since iOS 12.0 (replacement: `unarchivedObject(ofClass:from:)`)
