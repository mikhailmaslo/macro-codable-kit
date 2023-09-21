//
//  DateFormatterStrategy.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

/**
 A protocol for formatting dates into strings and converting strings back into dates.
 */
public protocol DateFormatterProtocol {
    /**
     Converts a `Date` object into a string representation.

     - Parameter date: The date to be converted.

     - Returns: A string representation of the date.
     */
    func string(from date: Date) -> String

    /**
     Converts a string representation of a date into a `Date` object.

     - Parameter string: The string representation of the date.

     - Returns: A `Date` object representing the date, or `nil` if the conversion fails.
     */
    func date(from string: String) -> Date?
}

/**
 A protocol for providing a `DateFormatterProtocol` instance.
 */
public protocol DateFormatterProvider {
    /// The `DateFormatterProtocol` instance.
    static var dateFormatter: DateFormatterProtocol { get }
}

/**
 A strategy for encoding and decoding `Date` values using a `DateFormatterProvider`.

 - Note: This strategy is used for encoding and decoding `Date` values as strings.
 */
public struct DateFormatterStrategy<Provider: DateFormatterProvider>: ValueCodableStrategy {
    /// The raw value type used for encoding and decoding.
    public typealias RawValue = String

    /// The value type being encoded and decoded.
    public typealias Value = Date

    /**
     Decodes a `Date` value from the given decoder.

     - Parameter decoder: The decoder to use for decoding.

     - Throws: `DecodingError.dataCorrupted` if the decoded value is not a valid date.

     - Returns: The decoded `Date` value.
     */
    public static func decode(from decoder: Decoder) throws -> Value {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(RawValue.self)
        guard let date = Provider.dateFormatter.date(from: value) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "'\(value)' is an invalid date format. Provider = \(Provider.self)"
                )
            )
        }
        return date
    }

    /**
     Encodes a `Date` value to the given encoder.

     - Parameter value: The `Date` value to encode.
     - Parameter encoder: The encoder to use for encoding.

     - Throws: An error if the encoding process fails.
     */
    public static func encode(value: Value, to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Provider.dateFormatter.string(from: value))
    }
}

#if canImport(Foundation)
    import Foundation

    extension ISO8601DateFormatter: DateFormatterProtocol {}

    extension DateFormatter: DateFormatterProtocol {}
#endif
