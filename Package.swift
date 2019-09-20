// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "WeatherFramework",
    platforms: [
        .iOS(SupportedPlatform.IOSVersion.v13),
        .watchOS(SupportedPlatform.WatchOSVersion.v6)
    ],
    products: [
        .library(name: "WeatherFramework", targets: ["WeatherFramework"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "WeatherFramework", dependencies: []),
        .testTarget(name: "WeatherFrameworkTests", dependencies: ["WeatherFramework"]),
    ]
)
