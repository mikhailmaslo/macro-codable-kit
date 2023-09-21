//
//  SafeDecoding+Array.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

// MARK: - Decoding

/**
 A `CustomCodable` strategy designed for safely decoding arrays, while gracefully handling decoding errors during the process. `SafeDecoding` provides a robust way to decode arrays, ensuring that decodable elements are captured and errors are logged for further inspection.

 - Usage:
    To utilize this strategy, annotate the property with `@CustomCoding(SafeDecoding)` and ensure that the parent type is annotated with `@Codable`, `@Decodable`, or `@Encodable` macros.

    ```swift
    @Codable
    struct ArrayExample: Equatable {
        @CustomCoding(SafeDecoding)
        var elements: [Element]
    }
    ```

 - Decoding:
    During decoding, `SafeDecoding` attempts to decode each element in the array. If an element fails to decode, it logs the error and continues to the next element, ensuring that all decodable elements are captured.

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
    Encoding with `SafeDecoding` follows the standard encoding process for arrays.

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

 - SeeAlso:
    - `CustomCoding`
    - `SafeDecoding`
 */
public extension CustomCodingDecoding {
    private struct AnyDecodableValue: Decodable {}

    /**
     Safely decodes an array of elements for a given key.

     - Parameters:
       - _: The type of the array elements.
       - forKey: The key to decode the array.
       - container: The container to decode from.

     - Throws: An error if decoding fails.

     - Returns: An array of decoded elements.
     */
    static func safeDecoding<K, Element: Decodable>(
        _: [Element].Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>
    ) throws -> [Element] {
        var elements: [Element] = []
        let decoder = try container.superDecoder(forKey: key)
        var container = try decoder.unkeyedContainer()

        while !container.isAtEnd {
            do {
                let value = try container.decode(Element.self)
                elements.append(value)
            } catch {
                _ = try? container.decode(AnyDecodableValue.self)

                logError(error)
            }
        }
        return elements
    }

    /**
     Safely decodes an optional array of elements for a given key.

     - Parameters:
       - _: The type of the array elements.
       - forKey: The key to decode the array.
       - container: The container to decode from.

     - Throws: An error if decoding fails.

     - Returns: An optional array of decoded elements, or `nil` if the key is not present.
     */
    static func safeDecoding<K, Element: Decodable>(
        _: [Element]?.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>
    ) throws -> [Element]? {
        if container.contains(key) {
            return try safeDecoding([Element].self, forKey: key, container: container)
        } else {
            return nil
        }
    }
}

// MARK: - Encoding

public extension CustomCodingEncoding {
    /**
     Default encode implementation of a dictionary

     - Parameters:
       - value: The array of elements to encode.
       - forKey: The key to encode the array.
       - container: The container to encode into.

     - Throws: An error if encoding fails.
     */
    static func safeDecoding<K, Element: Encodable>(
        _ value: [Element],
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>
    ) throws {
        try container.encode(value, forKey: key)
    }

    /**
     Default encode implementation of a dictionary

     - Parameters:
       - value: The optional array of elements to encode.
       - forKey: The key to encode the array.
       - container: The container to encode into.

     - Throws: An error if encoding fails.
     */
    static func safeDecoding<K, Element: Encodable>(
        _ value: [Element]?,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>
    ) throws {
        guard let value = value else { return }

        try safeDecoding(value, forKey: key, container: &container)
    }
}
