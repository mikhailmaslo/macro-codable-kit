//
//  CustomCodingEncoding.swift
//
//
//  Created by Mikhail Maslo on 03.10.23.
//

/**
 `CustomCodingEncoding` serves as a centralized extension for handling custom encoding strategies across various types. Through this extension, custom strategies are utilized to encode data, especially when specific handling is required. In case of encoding errors, they can be captured and logged for further investigation, ensuring a robust and error-resilient encoding process.

 Here are the main components and functionalities provided by `CustomCodingEncoding`:

 - `errorHandler`: A closure that captures and handles any errors encountered during the encoding process. The handling might include logging the error for debugging purposes or taking other actions as needed.

    ```swift
    /// A closure that handles encoding errors.
    public static var errorHandler: ((Error) -> Void)?
    ```

 - `logError(_:)`: A method to log errors encountered during the encoding process, which utilizes the `errorHandler` closure to manage the errors. This method is particularly useful when a custom encoding strategy encounters an error that needs to be logged but not halt the encoding process.

    ```swift
    /**
     Logs the given error using the `errorHandler` closure.

     - Parameter error: The error to log.
     */
    public static func logError(_ error: Error) {
        errorHandler?(error)
    }
    ```

 - Usage: `CustomCodingEncoding` comes into play when there's a custom encoding strategy associated with a type. For instance, when using `SafeDecoding` or `SafeDecoding` strategies, `CustomCodingEncoding` manages the encoding process and error handling.

    An example of a custom encoding strategy in use:

    ```swift
    @Codable
    struct DictionaryExample: Equatable {
        @CustomCoding(SafeDecoding)
        var entries: [Key: Value]
    }
    ```

    In this example, `SafeDecoding` is a custom encoding strategy, and `CustomCodingEncoding` will manage the encoding of the `entries` property, including error logging.

 - Note:
    While `CustomCodingEncoding` handles encoding, `CustomCodingDecoding` is used for decoding purposes, each having its specific error handling and logging mechanisms.

 - SeeAlso:
    - `CustomCodingDecoding`
    - `SafeDecoding`
    - `SafeDecoding`
 */
public enum CustomCodingEncoding {
    /// A closure that handles encoding errors.
    public static var errorHandler: ((Error) -> Void)?

    /**
     Logs the given error using the `errorHandler` closure.

     - Parameter error: The error to log.
     */
    public static func logError(_ error: Error) {
        errorHandler?(error)
    }
}
