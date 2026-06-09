// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HabitVotesCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "HabitVotesCore", targets: ["HabitVotesCore"]),
        .executable(name: "HabitVotesCoreChecks", targets: ["HabitVotesCoreChecks"])
    ],
    targets: [
        .target(name: "HabitVotesCore"),
        .executableTarget(name: "HabitVotesCoreChecks", dependencies: ["HabitVotesCore"]),
        .testTarget(name: "HabitVotesCoreTests", dependencies: ["HabitVotesCore"])
    ]
)
