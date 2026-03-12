// swift-tools-version: 5.10
import PackageDescription

let package = Package(
	name: "PhysisVAD",
	platforms: [
		.iOS("26.0"),
		.macOS("15.0"),
		.visionOS("2.0")
	],
	products: [
		.library(
			name: "PhysisVAD",
			targets: ["PhysisVAD"]
		)
	],
	targets: [
		.target(
			name: "PhysisVAD",
			resources: [
				.copy("Models")
			]
		),
		.testTarget(
			name: "PhysisVADTests",
			dependencies: ["PhysisVAD"]
		)
	]
)
