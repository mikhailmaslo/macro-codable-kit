//
//  RFC3339DateFormatterProvider.swift
//
//
//  Created by Mikhail Maslo on 02.10.23.
//

#if canImport(Foundation)
    import Foundation

    public typealias RFC3339Date = DateFormatterStrategy<RFC3339DateFormatterProvider>

    /**
     A provider for `DateFormatter` instances that use the RFC3339 date format.

     - Note: This provider is only available if `Foundation` can be imported.

     - SeeAlso: `DateFormatterStrategy`
     */
    public struct RFC3339DateFormatterProvider: DateFormatterProvider {
        /**
         The shared `DateFormatter` instance for RFC3339 date format.

         - Note: The date format follows the RFC3339 standard: "yyyy-MM-dd'T'HH:mm:ssZ".

         - Returns: A `DateFormatter` instance with the specified format.
         */
        public static let dateFormatter: DateFormatterProtocol = {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return dateFormatter
        }()
    }
#endif
