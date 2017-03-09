import PackageDescription

let package = Package(
    name: "SwiftUnsplash",
    dependencies: [
        .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON", majorVersion: 3)
    ]
)
