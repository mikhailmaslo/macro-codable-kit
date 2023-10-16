//
//  DateFormatterStrategy.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

/// Abstracts date formatters
public protocol DateFormatterProtocol {
    /// Converts a `Date` object into a string representation.
    func string(from date: Date) -> String

    /// Converts a string representation of a date into a `Date` object.
    func date(from string: String) -> Date?
}

/// Provides a `DateFormatterProtocol` instance.
public protocol DateFormatterProvider {
    static var dateFormatter: DateFormatterProtocol { get }
}

/// A strategy for encoding and decoding `Date` values using a `DateFormatterProvider`.
public struct DateFormatterStrategy<Provider: DateFormatterProvider>: ValueCodableStrategy {
    public typealias Value = Date

    /// Decodes a `String` value from the given decoder which then converts to `Date` using provided by date formatter from `Provider`.
    ///
    /// - Throws: `DecodingError.dataCorrupted` if formatting fails
    ///
    /// - Returns: The decoded `Data` value from base64 String.
    public static func decode(from decoder: Decoder) throws -> Value {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
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

    /// Encodes the given date `Date` value to the given encoder.
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
