//
//  Base64Strategy.swift
//
//
//  Created by Mikhail Maslo on 02.10.23.
//

#if canImport(Foundation)
    import Foundation

    /// Decodes base64 `String` into `Data` and encodes `Data` to base64 `String` in ``ValueStrategy(_:)``.
    public typealias Base64Data = Base64Strategy

    /// Decodes base64 `String` into `Data` and encodes `Data` to base64 `String`.
    public struct Base64Strategy: ValueCodableStrategy {
        public typealias Value = Data

        /// Decodes a `Data` value from base64 `String`.
        ///
        /// - Throws: `DecodingError.dataCorrupted` if the Base64 string is invalid.
        ///
        /// - Returns: The decoded `Data` value from base64 String.
        public static func decode(from decoder: Decoder) throws -> Value {
            let container = try decoder.singleValueContainer()
            let base64Encoded = try container.decode(String.self)
            if let data = Data(base64Encoded: base64Encoded) {
                return data
            } else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid Base64 string: \(base64Encoded)")
                )
            }
        }

        /// Encodes the given `Data` value to the given encoder as base64 String.
        public static func encode(value: Value, to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            let base64EncodedString = value.base64EncodedString()
            try container.encode(base64EncodedString)
        }
    }
#endif
