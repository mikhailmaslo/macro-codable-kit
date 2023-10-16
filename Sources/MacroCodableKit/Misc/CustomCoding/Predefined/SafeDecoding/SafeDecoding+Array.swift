//
//  SafeDecoding+Array.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

// MARK: - Decoding

public extension CustomCodingDecoding {
    private struct AnyDecodableValue: Decodable {}

    /// Decodes array, suppressing individual element which failed to decode.
    ///
    /// It logs the error and continues to the next element, ensuring that all decodable elements are captured.
    ///
    /// - Parameters:
    ///     - _: The type of the array elements.
    ///     - forKey: The key to decode the array.
    ///     - container: The container to decode from.
    ///
    /// - Throws: An error if decoding fails.
    ///
    /// - Returns: An optional array of decoded elements, or `nil` if the key is not present.
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

    /// Decodes array, suppressing individual element which failed to decode if `key` exists.
    ///
    /// It logs the error and continues to the next element, ensuring that all decodable elements are captured.
    ///
    /// - Parameters:
    ///     - _: The type of the array elements.
    ///     - forKey: The key to decode the array.
    ///     - container: The container to decode from.
    ///
    /// - Throws: An error if decoding fails.
    ///
    /// - Returns: An optional array of decoded elements, or `nil` if the key is not present.
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
    /// Default encode implementation of an array
    static func safeDecoding<K, Element: Encodable>(
        _ value: [Element],
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>
    ) throws {
        try container.encode(value, forKey: key)
    }

    /// Default encode implementation of an optional array
    static func safeDecoding<K, Element: Encodable>(
        _ value: [Element]?,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>
    ) throws {
        guard let value = value else { return }

        try safeDecoding(value, forKey: key, container: &container)
    }
}
