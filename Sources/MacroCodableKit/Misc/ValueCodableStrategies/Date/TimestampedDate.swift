//
//  TimestampedDate.swift
//
//
//  Created by Mikhail Maslo on 02.10.23.
//

#if canImport(Foundation)
    import Foundation

    public typealias TimestampedDate = TimestampStrategy
    /**
     A strategy for encoding and decoding `Date` values as timestamps.

     - SeeAlso: `ValueCodableStrategy`
     */
    public struct TimestampStrategy: ValueCodableStrategy {
        /// The type of value that this strategy encodes and decodes.
        public typealias Value = Date

        /**
         Decodes a `Date` value from the given decoder.

         - Parameter decoder: The decoder to read data from.

         - Throws: An error if the decoding process fails.

         - Returns: The decoded `Date` value.
         */
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

        /**
         Encodes the given `Date` value into the given encoder.

         - Parameter value: The `Date` value to encode.
         - Parameter encoder: The encoder to write data to.

         - Throws: An error if the encoding process fails.
         */
        public static func encode(value: Value, to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(value.timeIntervalSince1970)
        }
    }
#endif
