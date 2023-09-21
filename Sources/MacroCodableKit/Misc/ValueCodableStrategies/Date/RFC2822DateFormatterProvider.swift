//
//  RFC2822DateFormatterProvider.swift
//
//
//  Created by Mikhail Maslo on 02.10.23.
//

#if canImport(Foundation)
    import Foundation

    /// A typealias for `DateFormatterStrategy` using `RFC2822DateFormatterProvider`.
    public typealias RFC2822Date = DateFormatterStrategy<RFC2822DateFormatterProvider>

    /**
     A provider for `DateFormatter` with RFC2822 date format.

     - Important: The date format used is "EEE, d MMM y HH:mm:ss zzz".
     */
    public struct RFC2822DateFormatterProvider: DateFormatterProvider {
        /// The shared instance of `DateFormatter` with RFC2822 date format.
        public static let dateFormatter: DateFormatterProtocol = {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "EEE, d MMM y HH:mm:ss zzz"
            return dateFormatter
        }()
    }
#endif
