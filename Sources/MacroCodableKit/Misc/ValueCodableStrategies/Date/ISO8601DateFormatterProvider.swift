//
//  ISO8601DateFormatterProvider.swift
//
//
//  Created by Mikhail Maslo on 02.10.23.
//

#if canImport(Foundation)
    import Foundation

    // MARK: - ISO8601Default

    /// Decodes and encodes `yyyy-MM-dd'T'HH:mm:ssXXX` date in ``ValueStrategy(_:)``
    ///
    /// Example: `2023-10-03T10:15:30+00:00`
    public typealias ISO8601Default = DateFormatterStrategy<ISO8601DefaultDateFormatterProvider>

    /// Provides `yyyy-MM-dd'T'HH:mm:ssXXX` date formatter
    ///
    /// Example: `2023-10-03T10:15:30+00:00`
    public struct ISO8601DefaultDateFormatterProvider: DateFormatterProvider {
        public static let dateFormatter: DateFormatterProtocol = ISO8601DateFormatter()
    }

    // MARK: - ISO8601WithFullDate

    /// Decodes and encodes `yyyy-MM-dd` date in ``ValueStrategy(_:)``
    ///
    /// Example: `2023-10-03`
    public typealias ISO8601WithFullDate = DateFormatterStrategy<ISO8601FullDateDateFormatterProvider>

    /// Provides `yyyy-MM-dd` date formatter
    ///
    /// Example: `2023-10-03`
    public struct ISO8601FullDateDateFormatterProvider: DateFormatterProvider {
        public static let dateFormatter: DateFormatterProtocol = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = .withFullDate
            return formatter
        }()
    }

    // MARK: - ISO8601WithFractionalSeconds

    /// Decodes and encodes `yyyy-MM-dd'T'HH:mm:ss.SSSXXX` date in ``ValueStrategy(_:)``
    ///
    /// Example: `2023-10-03T10:15:30.123+00:00`
    public typealias ISO8601WithFractionalSeconds = DateFormatterStrategy<ISO8601WithFractionalSecondsDateFormatterProvider>

    /// Provides `yyyy-MM-dd'T'HH:mm:ss.SSSXXX` date formatter
    ///
    /// Example: `2023-10-03T10:15:30.123+00:00`
    public struct ISO8601WithFractionalSecondsDateFormatterProvider: DateFormatterProvider {
        public static let dateFormatter: DateFormatterProtocol = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter
        }()
    }

#endif
