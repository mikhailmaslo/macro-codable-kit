//
//  TimestampedDate.swift
//
//
//  Created by Mikhail Maslo on 02.10.23.
//

#if canImport(Foundation)
    import Foundation

    /// Decodes and encodes unix timestamp in ``ValueStrategy(_:)``.
    ///
    /// Works with `String` and `Double` representations.
    ///
    /// Example: `1696291200.0` or `"1696291200.0"`
    public typealias TimestampedDate = TimestampStrategy

    /// Decodes and encodes unix timestamp in ``ValueStrategy(_:)``.
    ///
    /// Works with `String` and `Double` representations.
    ///
    /// Example: `1696291200.0` or `"1696291200.0"`
    public struct TimestampStrategy: ValueCodableStrategy {
        public typealias Value = Date

        /// Decodes a `Date` value from the given decoder.
        ///
        /// - Parameter decoder: The decoder to read data from.
        ///
        /// - Throws: An error if coudn't decode either `String` or `TimeInterval` from decoder
        ///
        /// - Returns: The decoded `Date` value.
        public static func decode(from decoder: Decoder) throws -> Value {
            let container = try decoder.singleValueContainer()
            let timeInterval: TimeInterval?

            do {
                timeInterval = try container.decode(TimeInterval.self)
            } catch {
                timeInterval = (try? container.decode(String.self)).flatMap { Double($0) }
            }

            guard let timeInterval else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Couldn't decode neither TimeInterval nor String"
                    )
                )
            }
            return Date(timeIntervalSince1970: timeInterval)
        }

        /// Encodes the given `Date` value into the given encoder as `TimeInterval`.
        public static func encode(value: Value, to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(value.timeIntervalSince1970)
        }
    }
#endif
