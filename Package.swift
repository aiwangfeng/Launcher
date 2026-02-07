// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Launcher",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Launcher", targets: ["Launcher"])
    ],
    targets: [
        .executableTarget(
            name: "Launcher",
            path: "Sources/Launcher",
            exclude: ["Info.plist"],
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Sources/Launcher/Info.plist"])
            ]
        )
    ]
)
