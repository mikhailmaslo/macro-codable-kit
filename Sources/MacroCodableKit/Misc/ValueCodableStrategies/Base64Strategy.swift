//
//  Base64Strategy.swift
//
//
//  Created by Mikhail Maslo on 02.10.23.
//

/**
 A strategy for encoding and decoding Base64 data.
 
 - Note: This strategy requires the `Foundation` framework.
 
 - SeeAlso: `ValueCodableStrategy`
 */
#if canImport(Foundation)
    import Foundation

    /// A typealias for `Base64Strategy` to make it more readable.
    public typealias Base64Data = Base64Strategy

    /// A strategy for encoding and decoding Base64 data.
    public struct Base64Strategy: ValueCodableStrategy {
        /// The raw value type for this strategy.
        public typealias RawValue = String

        /// The value type for this strategy.
        public typealias Value = Data

        /**
         Decodes a `Data` value from the given decoder.

         - Parameter decoder: The decoder to use.

         - Throws: `DecodingError.dataCorrupted` if the Base64 string is invalid.

         - Returns: The decoded `Data` value.
         */
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

        /**
         Encodes the given `Data` value to the given encoder.

         - Parameter value: The `Data` value to encode.
         - Parameter encoder: The encoder to use.

         - Throws: An error if encoding fails.
         */
        public static func encode(value: Value, to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            let base64EncodedString = value.base64EncodedString()
            try container.encode(base64EncodedString)
        }
    }
#endif
