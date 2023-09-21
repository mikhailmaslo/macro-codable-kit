//
//  ISO8601DateFormatterProvider.swift
//
//
//  Created by Mikhail Maslo on 02.10.23.
//

#if canImport(Foundation)
    import Foundation

    // MARK: - ISO8601Default

    /// A default `DateFormatter` strategy for ISO8601 format.
    public typealias ISO8601Default = DateFormatterStrategy<ISO8601DefaultDateFormatterProvider>

    /**
     A provider for `ISO8601DateFormatter` instances with default format options.
     */
    public struct ISO8601DefaultDateFormatterProvider: DateFormatterProvider {
        /// The shared `ISO8601DateFormatter` instance with default format options.
        public static let dateFormatter: DateFormatterProtocol = ISO8601DateFormatter()
    }

    // MARK: - ISO8601WithFullDate

    /// A `DateFormatter` strategy for ISO8601 format with full date.
    public typealias ISO8601WithFullDate = DateFormatterStrategy<ISO8601FullDateDateFormatterProvider>

    /**
     A provider for `ISO8601DateFormatter` instances with full date format option.
     */
    public struct ISO8601FullDateDateFormatterProvider: DateFormatterProvider {
        /// The shared `ISO8601DateFormatter` instance with full date format option.
        public static let dateFormatter: DateFormatterProtocol = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = .withFullDate
            return formatter
        }()
    }

    // MARK: - ISO8601WithFractionalSeconds

    /// A `DateFormatter` strategy for ISO8601 format with fractional seconds.
    public typealias ISO8601WithFractionalSeconds = DateFormatterStrategy<ISO8601WithFractionalSecondsDateFormatterProvider>

    /**
     A provider for `ISO8601DateFormatter` instances with internet date time and fractional seconds format options.
     */
    public struct ISO8601WithFractionalSecondsDateFormatterProvider: DateFormatterProvider {
        /// The shared `ISO8601DateFormatter` instance with internet date time and fractional seconds format options.
        public static let dateFormatter: DateFormatterProtocol = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter
        }()
    }

#endif
