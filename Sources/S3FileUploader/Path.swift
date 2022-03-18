// Copyright (c) 2022 Bob
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import ArgumentParser
import Foundation
import TSCBasic

extension AbsolutePath {
    func exist() -> Bool {
        return FileManager.default.fileExists(atPath: pathString)
    }

    func isFile() -> Bool {
        return localFileSystem.isFile(self)
    }

    func size() -> UInt64 {
        return try! localFileSystem.getFileInfo(self).size
    }
}

var homeDirectoryForCurrentUser: AbsolutePath {
    return AbsolutePath(NSHomeDirectory())
}

extension AbsolutePath {
    init(expandingTilde path: String) {
        if path.first == "~" {
            self.init(homeDirectoryForCurrentUser, String(path.dropFirst(2)))
        } else {
            self.init(path)
        }
    }
}

extension AbsolutePath: ExpressibleByArgument {
    public init?(argument: String) {
        if let cwd = localFileSystem.currentWorkingDirectory {
            self.init(argument, relativeTo: cwd)
        } else {
            guard let path = try? AbsolutePath(validating: argument) else {
                return nil
            }
            self = path
        }
    }

    public static var defaultCompletionKind: CompletionKind {
        // This type is most commonly used to select a directory, not a file.
        // Specify '.file()' in an argument declaration when necessary.
        .directory
    }
}
