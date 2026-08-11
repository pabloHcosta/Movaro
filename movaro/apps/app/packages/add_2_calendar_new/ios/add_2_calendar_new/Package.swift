// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "add_2_calendar_new",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "add-2-calendar-new", targets: ["add_2_calendar_new"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "add_2_calendar_new",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
