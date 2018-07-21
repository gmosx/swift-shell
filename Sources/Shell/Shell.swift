import Foundation
import Basic
import Utility

// TODO: Split in multiple files
// TODO: Rename to ShellClient, ShellDriver or ShellUtils? -> nah...
// TODO: support streaming output.
// TODO: extract filesystem related functionality as FileSystem package

public extension String {
    func escapingForShell() -> String {
        return self
            .replacingOccurrences(of: "&", with: "\\&")
            .replacingOccurrences(of: "!", with: "\\!")
    }
}

/// A programming interface for accessing operating system services
public class Shell {
    let isVerbose: Bool

    public init(verbose: Bool = true) {
        self.isVerbose = verbose
    }

    public func log(_ text: String) {
        if isVerbose {
            print(text)
        }
    }

    public var fileManager: FileManager {
        return FileManager.default
    }

    // TODO: extract functionality, add tests!
    // TODO: consider returning `nil` if there is no basePath
    public func basePath(ofPath path: String) -> String {
        return path.split(separator: "/").dropLast().joined(separator: "/")
    }

    @discardableResult
    public func execute(_ command: String) throws -> ProcessResult {
        log(command)

        let process = Process(arguments: ["sh", "-c", command])
        try process.launch()

        let result = try process.waitUntilExit()

        if let output = try? result.utf8Output() {
            print(output, terminator: "")
        }

        switch result.exitStatus {
        case .terminated(let status):
            if status != 0 {
                if let output = try? result.utf8stderrOutput() {
                    print(output, terminator: "")
                }
                break
            }

        default:
            break
        }

        return result
    }

    public func execute(script: String) throws {
        for scriptCommand in script.split(separator: "\n") {
            try execute(String(scriptCommand))
        }
    }

    public var currentDirectoryPath: String {
        return fileManager.currentDirectoryPath
    }

    public func ensureDirectoryExists(atPath path: String) throws {
        if !fileManager.fileExists(atPath: path) {
            log("Created \(path)")
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
    }

    // TODO: allow override/not-override
    public func writeTextFile(atPath path: String, contents: String, withIntermediateDirectories: Bool = true) throws {
        if withIntermediateDirectories {
            let directoryPath = basePath(ofPath: path)
            if directoryPath != "" {
                try ensureDirectoryExists(atPath: directoryPath)
            }
        }

        try contents.write(to: URL(fileURLWithPath: path), atomically: false, encoding: .utf8)
        log("Created \(path)")
    }

    public func copyFile(atPath srcPath: String, toPath dstPath: String, force: Bool = false, withIntermediateDirectories: Bool = true) throws {
        if force {
            if fileManager.fileExists(atPath: dstPath) {
                try removeFile(atPath: dstPath)
            }
        }

        if withIntermediateDirectories {
            try ensureDirectoryExists(atPath: basePath(ofPath: dstPath))
        }

        try fileManager.copyItem(atPath: srcPath, toPath: dstPath)

        log("Copied \(srcPath) to \(dstPath)")
    }

    public func removeFile(atPath path: String) throws {
        try fileManager.removeItem(atPath: path)
        log("Removed \(path)")
    }

    public func removeDirectory(atPath path: String) throws {
        try fileManager.removeItem(atPath: path)
        log("Removed \(path)")
    }

    public func isDirectory(_ path: String) -> Bool {
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }

    public func isFile(_ path: String) -> Bool {
        return !isDirectory(path)
    }

    public func subpaths(atPath path: String) -> [String] {
        return fileManager.subpaths(atPath: path) ?? []
    }

    public func subfilepaths(atPath path: String) -> [String] {
        return fileManager.subpaths(atPath: path)?.filter({ isFile("\(path)/\($0)") }) ?? []
    }

    public func confirm(_ message: String) -> Bool {
        print("\(message) [yes/NO]", terminator: " ")

        let didConfirm: Bool

        if let input = readLine() {
            didConfirm = input.lowercased() == "yes"
        } else {
            didConfirm = false
        }

        return didConfirm
    }
}
