// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "WeatherFramework",
    platforms: [
        .iOS(SupportedPlatform.IOSVersion.v14),
        .watchOS(SupportedPlatform.WatchOSVersion.v7)
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
