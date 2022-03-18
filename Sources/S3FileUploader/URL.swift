// Copyright (c) 2022 Bob
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import CryptoKit
import Foundation

extension URL {
    func fileMD5() -> String? {
        let bufferSize = 16 * 1024
        do {
            let file = try FileHandle(forReadingFrom: self)
            defer {
                file.closeFile()
            }
            var md5 = Insecure.MD5()
            while autoreleasepool(invoking: {
                let data = file.readData(ofLength: bufferSize)
                if !data.isEmpty {
                    md5.update(data: data)
                    return true // Continue
                } else {
                    return false // End of file
                }
            }) {}

            let data = Data(md5.finalize())
            return data.base64EncodedString()
        } catch {
            return nil
        }
    }
}
