import Foundation

public struct ChecklistEngine {
    public init() {}

    public func welcomeMessage(arguments: [String]) -> String {
        var lines: [String] = []
        lines.append("Checklist Core 👋")
        if arguments.isEmpty {
            lines.append("No arguments provided. Example: `swift run checklist --help`")
        } else if let first = arguments.first, ["--help", "-h"].contains(first) {
            lines.append("Usage: checklist [--help]\\nA starter Swift CLI/iOS-ready core.")
        } else {
            lines.append("Args: \(arguments.joined(separator: ", "))")
        }
        return lines.joined(separator: "\n")
    }
}
