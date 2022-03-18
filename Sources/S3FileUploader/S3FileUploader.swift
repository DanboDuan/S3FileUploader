// Copyright (c) 2022 Bob
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import CryptoKit
import Foundation
import TSCBasic

public final class S3FileUploader: NSObject {
    let host: String
    let accessKey: String
    let secretKey: String
    let utcDateFormatter = DateFormatter()
    init(host: String,
         accessKey: String,
         secretKey: String)
    {
        self.host = host
        self.accessKey = accessKey
        self.secretKey = secretKey
        super.init()
        utcDateFormatter.locale = Locale(identifier: "en_US")
        utcDateFormatter.dateFormat = "EE, dd MMM yyyy HH:mm:ss"
        utcDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    }

    private func makeUTCDate() -> String {
        let date = Date()
        return utcDateFormatter.string(from: date) + " GMT"
    }

    private func makeCanonicalHeader(method: String, path: String, header: [String: Any]) -> String {
        let keys = ["content-md5", "content-type", "date"]
        var interesting: [(String, String)] = header.compactMap { (key: String, value: Any) in
            let lk = key.lowercased()
            if lk.hasPrefix("x-amz-") {
                return (lk, "\(lk):\(String(describing: value))")
            }
            if keys.contains(lk) {
                return (lk, String(describing: value))
            }

            return nil
        }

        interesting.sort {
            $0.0.compare($1.0) == .orderedAscending
        }
        interesting.insert(("", method), at: 0)
        interesting.append(("", path))
        let data = interesting.map { $0.1 }.joined(separator: "\n")

        return data
    }

    private func makeAuthorization(path: String, header: [String: Any], method: String = "PUT") -> String {
        guard let canonical = makeCanonicalHeader(method: method, path: path, header: header).data(using: .utf8) else {
            fatalError("error")
        }
        guard let key = secretKey.data(using: .utf8) else {
            fatalError("error")
        }
        let code = HMAC<Insecure.SHA1>.authenticationCode(for: canonical, using: SymmetricKey(data: key))
        let hash = Data(code).base64EncodedString()
        return "AWS \(accessKey):\(hash)"
    }

    private func makeRequest(_ key: String, _ file: AbsolutePath) -> URLRequest {
        let URL = URL(string: "http://\(host)/\(key)")!
        var request = URLRequest(url: URL)
        var header = [String: String]()
        header["Date"] = makeUTCDate()
        header["Host"] = host
        header["x-amz-acl"] = "public-read"
        header["Content-Type"] = "application/octet-stream"
        header["Accept-Encoding"] = "identity"
        header["Content-MD5"] = file.asURL.fileMD5()!
        header["Content-Length"] = String(file.size())
        header["Authorization"] = makeAuthorization(path: URL.path, header: header)
        request.httpMethod = "PUT"
        request.timeoutInterval = 10 * 60
        request.allHTTPHeaderFields = header

        return request
    }

    func uploadFile(_ file: AbsolutePath, _ name: String,_ bucket: String) -> String? {
        guard file.isFile() else {
            echo("file ==>", file.pathString, "not exist")
            return nil
        }
        let path = "\(bucket)/\(name)"
        let request = makeRequest(path, file)
        echo("upload file ==>", file.pathString)
        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        let task = URLSession.shared.uploadTask(with: request, fromFile: file.asURL) { data, resp, error in
            if let resp = resp as? HTTPURLResponse, resp.statusCode == 200 {
                echo("upload success")
                success = true
            } else if let data = data, let log = String(data: data, encoding: .utf8) {
                echo("upload fail, message ==> ", log)
            }

            if let error = error {
                echo(error, color: .red)
                success = false
            }
            semaphore.signal()
        }
        if #available(macOS 12.0, *) {
            task.delegate = self
        }
        task.resume()
        semaphore.wait()
        if success {
            let result = "http://\(host)/\(path)"
            echo("Downalod URL ==>", result)
            return result
        }

        return nil
    }
}

extension S3FileUploader: URLSessionTaskDelegate {
    public func urlSession(_: URLSession,
                    task _: URLSessionTask,
                    didSendBodyData _: Int64,
                    totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64)
    {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend) * 100
        echo("upload progress ==> %\(progress)")
    }
}
