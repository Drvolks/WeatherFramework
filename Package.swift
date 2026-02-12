// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "WeatherFramework",
    platforms: [
        .iOS("26.0"),
        .watchOS("26.0")
    ],
    products: [
        .library(name: "WeatherFramework", targets: ["WeatherFramework"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "WeatherFramework", dependencies: []),
        .testTarget(name: "WeatherFrameworkTests", dependencies: ["WeatherFramework"]),
    ],
    swiftLanguageModes: [.v5]
)
