import Foundation
/**
 Create DMG for your Mac app

 - parameters:
   - path: Path to the directory to be archived to dmg
   - outputPath: The name of the resulting dmg file
   - volumeName: The volume name of the resulting image
   - filesystem: The filesystem of the resulting image
   - format: The format of the resulting image
   - size: Size of the resulting dmg file in megabytes

 - returns: The path of the output dmg file

 Use this action to create dmg for Mac app
*/
public func dmg(path: String,
                outputPath: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                volumeName: OptionalConfigValue<String?> = .fastlaneDefault(nil),
                filesystem: String = "HFS+",
                format: String = "UDZO",
                size: OptionalConfigValue<Int?> = .fastlaneDefault(nil)) {
let pathArg = RubyCommand.Argument(name: "path", value: path, type: nil)
let outputPathArg = outputPath.asRubyArgument(name: "output_path", type: nil)
let volumeNameArg = volumeName.asRubyArgument(name: "volume_name", type: nil)
let filesystemArg = RubyCommand.Argument(name: "filesystem", value: filesystem, type: nil)
let formatArg = RubyCommand.Argument(name: "format", value: format, type: nil)
let sizeArg = size.asRubyArgument(name: "size", type: nil)
let array: [RubyCommand.Argument?] = [pathArg,
outputPathArg,
volumeNameArg,
filesystemArg,
formatArg,
sizeArg]
let args: [RubyCommand.Argument] = array
.filter { $0?.value != nil }
.compactMap { $0 }
let command = RubyCommand(commandID: "", methodName: "dmg", className: nil, args: args)
  _ = runner.executeCommand(command)
}
