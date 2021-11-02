// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
    func releaseLane() {
        desc("Build & pack a new release")

        // Constants
        let target = "SimpleDesktops"
        let outputDirectory = URL(fileURLWithPath: "./.build", isDirectory: true)
        let packageName = "\(target)_v\(getVersionNumber(target: .userDefined(target)))"
        let packageDirectory = outputDirectory.appendingPathComponent(
            packageName,
            isDirectory: true
        )

        // Build app
        xcversion(version: "~> 13.1")
        let appPath = URL(fileURLWithPath: buildMacApp(
            scheme: .userDefined(target),
            outputDirectory: outputDirectory.path,
            codesigningIdentity: "-",
            exportMethod: "mac-application"
        ))

        // Move .app to folder
        try? FileManager.default.createDirectory(
            at: packageDirectory,
            withIntermediateDirectories: false,
            attributes: nil
        )
        try? FileManager.default.moveItem(
            at: appPath,
            to: packageDirectory.appendingPathComponent(appPath.lastPathComponent)
        )

        // Create image
        dmg(path: packageDirectory.path, size: 10)
    }
}
