//
//  CodableKitUtils.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

/**
 `CustomCodingDecoding` serves as a centralized extension for handling custom decoding strategies across various types. Through this extension, custom strategies are utilized to decode data, especially when specific handling is required. In case of decoding errors, they can be captured and logged for further investigation, ensuring a robust and error-resilient decoding process.

 Here are the main components and functionalities provided by `CustomCodingDecoding`:

 - `errorHandler`: A closure that captures and handles any errors encountered during the decoding process. The handling might include logging the error for debugging purposes or taking other actions as needed.

    ```swift
    static var errorHandler: ((Error) -> Void)?
    ```

 - `logError(_:)`: A method to log errors encountered during the decoding process, which utilizes the `errorHandler` closure to manage the errors. This method is particularly useful when a custom decoding strategy encounters an error that needs to be logged but not halt the decoding process.

    ```swift
    public static func logError(_ error: Error) {
        errorHandler?(error)
    }
    ```

 - Usage: `CustomCodingDecoding` comes into play when there's a custom decoding strategy associated with a type. For instance, when using `SafeDecoding` or `SafeDecoding` strategies, `CustomCodingDecoding` manages the decoding process and error handling.

    An example of a custom decoding strategy in use:

    ```swift
    @Codable
    struct ArrayExample: Equatable {
        @CustomCoding(SafeDecoding)
        var elements: [Element]
    }
    ```

    In this example, `SafeDecoding` is a custom decoding strategy, and `CustomCodingDecoding` will manage the decoding of the `elements` property, including error logging.

 - Note:
    While `CustomCodingDecoding` handles decoding, `CustomCodingEncoding` is used for encoding purposes, each having its specific error handling and logging mechanisms.

 - SeeAlso:
    - `CustomCodingEncoding`
    - `SafeDecoding`
    - `SafeDecoding`
 */
public enum CustomCodingDecoding {
    /// A closure that handles errors during coding and decoding operations.
    static var errorHandler: ((Error) -> Void)?

    /**
     Logs an error during coding and decoding operations.

     - Parameter error: The error to be logged.
     */
    public static func logError(_ error: Error) {
        errorHandler?(error)
    }
}
