// Copyright (c) 2022 Bob
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import ArgumentParser
import Foundation
import TSCBasic

struct Options: ParsableArguments {
    @Option(
        name: [.customLong("file")],
        help: "file path"
    )
    var file: AbsolutePath

    @Option(
        name: [.customLong("key")],
        help: "s3 url key suffix"
    )
    var key: String

    @Option(
        name: [.customLong("bucket")],
        help: "bucket"
    )
    var bucket: String

    @Option(
        name: [.customLong("host")],
        help: "host"
    )
    var host: String

    @Option(
        name: [.customLong("accessKey")],
        help: "accessKey"
    )
    var accessKey: String

    @Option(
        name: [.customLong("secretKey")],
        help: "secretKey"
    )
    var secretKey: String
}
