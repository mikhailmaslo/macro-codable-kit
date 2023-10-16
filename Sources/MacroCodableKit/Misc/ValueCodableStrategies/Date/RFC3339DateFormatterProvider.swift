//
//  RFC3339DateFormatterProvider.swift
//
//
//  Created by Mikhail Maslo on 02.10.23.
//

#if canImport(Foundation)
    import Foundation

    /// Decodes and encodes `yyyy-MM-dd'T'HH:mm:ssZ` date in ``ValueStrategy(_:)``
    ///
    /// Example: `2023-10-03T10:15:30Z`
    public typealias RFC3339Date = DateFormatterStrategy<RFC3339DateFormatterProvider>

    /// Provides `yyyy-MM-dd'T'HH:mm:ssZ` date formatter
    ///
    /// - Note: Uses `+0` time zone
    ///
    /// Example: `2023-10-03T10:15:30Z`
    public struct RFC3339DateFormatterProvider: DateFormatterProvider {
        public static let dateFormatter: DateFormatterProtocol = {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return dateFormatter
        }()
    }
#endif
