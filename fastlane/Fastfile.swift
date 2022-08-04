// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
    func releaseLane(withOptions options: [String: String]?) {
        desc("Build & pack a new release")

        // Constants
        let target = "SimpleDesktops"
        let version = options?["version"] ?? getVersionNumber(target: .userDefined(target))
        let build = options?["build"] ?? getBuildNumber()
        let packageName = "\(target)_v\(version)"
        let outputDirectory = URL(fileURLWithPath: "./.build", isDirectory: true)

        // Bump version
        incrementVersionNumber(versionNumber: .userDefined(version))
        incrementBuildNumber(buildNumber: .userDefined(build))

        // Build app
        xcversion(version: "~> 13.1")
        let appPath = URL(fileURLWithPath: buildMacApp(
            scheme: .userDefined(target),
            outputDirectory: outputDirectory.path,
            codesigningIdentity: "-",
            exportMethod: "mac-application",
            xcodebuildFormatter: "xcpretty"
        ))

        // Move .app to folder (exclude .dSYM file)
        let packageDirectory = outputDirectory.appendingPathComponent(
            packageName,
            isDirectory: true
        )
        try? FileManager.default.createDirectory(
            at: packageDirectory,
            withIntermediateDirectories: false,
            attributes: nil
        )
        try? FileManager.default.moveItem(
            at: appPath,
            to: packageDirectory.appendingPathComponent(appPath.lastPathComponent)
        )

        // Create DMG image
        let dmgPath = outputDirectory.appendingPathComponent("\(packageName).dmg")
        dmg(path: packageDirectory.path, outputPath: .userDefined(dmgPath.path), size: 10)
    }
}
