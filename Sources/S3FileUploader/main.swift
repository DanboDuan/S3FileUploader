// Copyright (c) 2022 Bob
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import ArgumentParser

struct Main: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "S3FileUploader",
        abstract: "S3FileUploader",
        version: "1.0.0"
    )

    @OptionGroup()
    var options: Options

    func validate() throws {
        guard options.file.isFile() else {
            throw ValidationError("\(options.file.pathString) not exist or is a directory")
        }
    }

    func run() throws {
        let s3 = S3FileUploader(host: options.host, accessKey: options.accessKey, secretKey: options.secretKey)
        let file = options.file
        if let downloadURL = s3.uploadFile(file, options.key, options.bucket) {
            echo("upload file", file.pathString, "to", downloadURL)
        } else {
            error("upload file", file.pathString, "failed")
        }
    }
}

Main.main()
