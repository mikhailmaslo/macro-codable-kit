//
//  SafeDecoding.swift
//
//
//  Created by Mikhail Maslo on 04.10.23.
//

/**
 A `CustomCodable` strategy designed for safely decoding arrays and dictionaries, while gracefully handling decoding errors during the process. `SafeDecoding` provides a robust way to decode collections, ensuring that decodable elements are captured and errors are logged for further inspection.

 - Usage:
    To utilize this strategy, annotate the property with `@CustomCoding(SafeDecoding)` and ensure that the parent type is annotated with `@Codable`, `@Decodable`, or `@Encodable` macros.

    ```swift
    @Codable
    struct CollectionExample: Equatable {
        @CustomCoding(SafeDecoding)
        var elements: [String]

        @CustomCoding(SafeDecoding)
        var dictionary: [String: Int]
    }
    ```

 - SafeDecoding with Arrays:
     Provides a robust way to decode arrays, ensuring that decodable elements are captured and errors are logged for further inspection.

     - Usage:
        ```swift
        @Codable
        struct ArrayExample: Equatable {
            @CustomCoding(SafeDecoding)
            var elements: [Element]
        }
        ```

     - Decoding:
        Attempts to decode each element in the array. If an element fails to decode, it logs the error and continues to the next element, ensuring that all decodable elements are captured.

        ```swift
        static func safeDecoding<K, Element: Decodable>(
            _: [Element].Type,
            forKey key: KeyedDecodingContainer<K>.Key,
            container: KeyedDecodingContainer<K>
        ) throws -> [Element] { ... }
        ```

        For decoding optional arrays, it checks if the key is present, and if so, proceeds to decode the array. If the key is not present, it returns `nil`.

        ```swift
        static func safeDecoding<K, Element: Decodable>(
            _: [Element]?.Type,
            forKey key: KeyedDecodingContainer<K>.Key,
            container: KeyedDecodingContainer<K>
        ) throws -> [Element]? { ... }
        ```

     - Encoding:
        Follows the standard encoding process for arrays.

        ```swift
        static func safeDecoding<K, Element: Encodable>(
            _ value: [Element],
            forKey key: KeyedEncodingContainer<K>.Key,
            container: inout KeyedEncodingContainer<K>
        ) throws { ... }

        static func safeDecoding<K, Element: Encodable>(
            _ value: [Element]?,
            forKey key: KeyedEncodingContainer<K>.Key,
            container: inout KeyedEncodingContainer<K>
        ) throws { ... }
        ```

 - SafeDecoding with Dictionaries:
     Designed for safely decoding dictionaries, particularly handling keys of type `String` or `Int`. Provides robust decoding, gracefully handling errors during the decoding process, with optional support for custom `KeyDecodingStrategy` when used with `JSONDecoder`.

     - Usage:
        ```swift
        @Codable
        struct DictionaryExample: Equatable {
            @CustomCoding(SafeDecoding)
            var entries: [String: Element]
        }
        ```

     - Decoding:
        First checks the type of the key. If it's a `String` or `Int`, the decoding proceeds, otherwise an error is thrown. It then creates a decoding container for the dictionary, iterates through the keys, and tries to decode each value. If a value fails to decode, it logs the error and continues to the next key, ensuring that all decodable values are captured.

     - Encoding:
        Follows the standard encoding process for dictionaries.

     - Custom `KeyDecodingStrategy` Support (Optional):
        Supports custom `KeyDecodingStrategy` when used alongside `JSONDecoder`, allowing for handling different key decoding strategies during the decoding process, for example, converting snake_case keys to camelCase.

 - Note:
    This strategy is part of the `CustomCodable` suite of tools which enable custom encoding and decoding strategies for properties.

 - SeeAlso:
    - `CustomCoding`
 */
public struct SafeDecoding: CustomDecodingName {}
