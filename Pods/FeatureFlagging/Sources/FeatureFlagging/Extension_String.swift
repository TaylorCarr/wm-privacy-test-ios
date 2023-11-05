//
//  File.swift
//
//
//  Created by Dan Esrey on 4/14/20.
//

import CommonCrypto
import Foundation

extension String {
//    func hmac(key: String) -> String {
//        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
//        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, self, self.count, &digest)
//        let data = Data(digest)
//        return data.map { String(format: "%02hhx", $0) }.joined()
//    }

    func sha256() -> String {
        if let stringData = data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }

    private func digest(input: NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }

    private func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)

        var hexString = ""
        for byte in bytes {
            hexString += String(format: "%02x", UInt8(byte))
        }

        return hexString
    }

    static let appUserId = "appUserId"
    static let boolean = "boolean"
    static let brands = "brands"
    static let etag = "Etag"
    static let ffUserId = "ffUserId"
    static let platform = "platform"
    static let ffLibraryLanguage = "fflibrarylanguage"
    static let ffLibaryVersionCode = "fflibraryversioncode"
}
