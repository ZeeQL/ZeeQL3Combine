// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "ZeeQL3Combine",

  products: [ // TBD: Use ZeeQL3 as library name?
    .library(name: "ZeeQLCombine", targets: [ "ZeeQLCombine" ])
  ],
  dependencies: [
    .package(url: "https://github.com/ZeeQL/ZeeQL3.git",
             from: "0.8.10")
  ],
  targets: [
    .target(name: "ZeeQLCombine", dependencies: [ "ZeeQL" ])
  ]
)
