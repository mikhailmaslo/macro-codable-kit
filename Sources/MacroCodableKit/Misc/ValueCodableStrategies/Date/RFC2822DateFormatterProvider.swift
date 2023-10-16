//
//  RFC2822DateFormatterProvider.swift
//
//
//  Created by Mikhail Maslo on 02.10.23.
//

#if canImport(Foundation)
    import Foundation

    /// Decodes and encodes `EEE, d MMM y HH:mm:ss zzz` date in ``ValueStrategy(_:)``
    ///
    /// Example: `Tue, 3 Oct 2023 10:15:30 GMT`
    public typealias RFC2822Date = DateFormatterStrategy<RFC2822DateFormatterProvider>

    /// Provides `EEE, d MMM y HH:mm:ss zzz` date formatter
    ///
    /// - Note: Uses `+0` time zone
    ///
    /// Example: `2023-10-03T10:15:30.123+00:00`
    public struct RFC2822DateFormatterProvider: DateFormatterProvider {
        public static let dateFormatter: DateFormatterProtocol = {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "EEE, d MMM y HH:mm:ss zzz"
            return dateFormatter
        }()
    }
#endif
