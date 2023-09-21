//
//  SafeDecoding+Dictionary.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

#if canImport(Foundation)
    import Foundation

    protocol KeyDecodingStrategyProvider {
        var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
    }

    extension JSONDecoder: KeyDecodingStrategyProvider {}
#endif

// MARK: - Decoding

/**
 A `CustomCodable` strategy designed for safely decoding dictionaries, particularly handling keys of type `String` or `Int`. `SafeDecoding` aims to provide robust decoding, gracefully handling errors during the decoding process, while also providing optional support for custom `KeyDecodingStrategy` when used with `JSONDecoder`.

 - Usage:
    To utilize this strategy, annotate the property with `@CustomCoding(SafeDecoding)` and ensure that the parent type is annotated with `@Codable`, `@Decodable`, or `@Encodable` macros.

    ```swift
    @Codable
    struct DictionaryExample: Equatable {
        @CustomCoding(SafeDecoding)
        var entries: [String: Element]
    }
    ```

 - Decoding:
    During decoding, `SafeDecoding` first checks the type of the key. If it's a `String` or `Int`, the decoding proceeds, otherwise an error is thrown. It then creates a decoding container for the dictionary, iterates through the keys, and tries to decode each value. If a value fails to decode, it logs the error and continues to the next key, ensuring that all decodable values are captured.

 - Encoding:
    Encoding with `SafeDecoding` follows the standard encoding process for dictionaries.

 - Custom `KeyDecodingStrategy` Support (Optional, requires Foundation):
    When used alongside `JSONDecoder`, `SafeDecoding` supports custom `KeyDecodingStrategy`. It allows for handling different key decoding strategies during the decoding process, for example, converting snake_case keys to camelCase.

 - SeeAlso:
    - `CustomCoding`
    - `SafeDecoding`
 */
public extension CustomCodingDecoding {
    private struct AnyDecodableValue: Decodable {}
    // Copy of https://github.com/apple/swift/blob/c0dc3173b6970466434770927aaaeaeb46f0cc10/stdlib/public/core/Codable.swift.gyb#L1974
    internal struct _DictionaryCodingKey: CodingKey {
        public var stringValue: String
        public var intValue: Int?

        public init?(stringValue: String) {
            self.stringValue = stringValue
            intValue = Int(stringValue)
        }

        public init?(intValue: Int) {
            self.intValue = intValue
            stringValue = String(intValue)
        }
    }

    static func safeDecoding<K, Key: Decodable, Value: Decodable>(
        _: [Key: Value].Type,
        forKey dictKey: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>
    ) throws -> [Key: Value] {
        if Key.self == String.self {
            var result: [Key: Value] = [:]
            let decoder = try container.superDecoder(forKey: dictKey)
            let container = try decoder.container(keyedBy: _DictionaryCodingKey.self)

            #if canImport(Foundation)
                switch (decoder as? KeyDecodingStrategyProvider)?.keyDecodingStrategy {
                case .useDefaultKeys:
                    for key in container.allKeys {
                        do {
                            let value = try container.decode(Value.self, forKey: key)
                            result[key.stringValue as! Key] = value
                        } catch {
                            _ = try? container.decode(AnyDecodableValue.self, forKey: key)
                        }
                    }
                default:
                    // We have to sort keys in order to match keys with snake case with camel case
                    // keys which respect `keyDecodingStrategy`
                    let resultKeys = try decoder.singleValueContainer()
                        .decode([String: AnyDecodableValue].self)
                        .keys
                        .sorted()
                    // keys as they appear in container
                    let rawKeys = container
                        .allKeys
                        .sorted(by: { $0.stringValue < $1.stringValue })

                    assert(resultKeys.count == rawKeys.count)

                    var resultKeyIndex = resultKeys.startIndex
                    var rawKeyIndex = rawKeys.startIndex
                    while resultKeyIndex < resultKeys.endIndex, rawKeyIndex < rawKeys.endIndex {
                        let rawKey = rawKeys[rawKeyIndex]
                        let resultKey = resultKeys[resultKeyIndex]

                        do {
                            let value = try container.decode(Value.self, forKey: rawKey)
                            result[resultKey as! Key] = value
                        } catch {
                            _ = try? container.decode(AnyDecodableValue.self, forKey: rawKey)
                        }

                        rawKeyIndex = rawKeys.index(after: rawKeyIndex)
                        resultKeyIndex = resultKeys.index(after: resultKeyIndex)
                    }
                }
            #else
                for key in container.allKeys {
                    do {
                        let value = try container.decode(Value.self, forKey: key)
                        result[key.stringValue as! Key] = value
                    } catch {
                        _ = try? container.decode(AnyDecodableValue.self, forKey: key)
                    }
                }
            #endif
            return result
        } else if Key.self == Int.self {
            var result: [Key: Value] = [:]
            let decoder = try container.superDecoder(forKey: dictKey)
            let container = try decoder.container(keyedBy: _DictionaryCodingKey.self)
            for key in container.allKeys {
                guard key.intValue != nil else {
                    var codingPath = decoder.codingPath
                    codingPath.append(key)
                    throw DecodingError.typeMismatch(
                        Int.self, DecodingError.Context(
                            codingPath: codingPath,
                            debugDescription: "Expected Int key but found String key instead."
                        )
                    )
                }

                do {
                    let value = try container.decode(Value.self, forKey: key)
                    result[key.intValue! as! Key] = value
                } catch {
                    _ = try? container.decode(AnyDecodableValue.self, forKey: key)
                }
            }
            return result
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Couldn't decode key of type \(Key.self)"
                )
            )
        }
    }

    static func safeDecoding<K, Key: Decodable, Value: Decodable>(
        _: [Key: Value]?.Type,
        forKey dictKey: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>
    ) throws -> [Key: Value]? {
        if container.contains(dictKey) {
            return try safeDecoding([Key: Value].self, forKey: dictKey, container: container)
        } else {
            return nil
        }
    }
}

// MARK: - Encoding

public extension CustomCodingEncoding {
    static func safeDecoding<K, Key: Encodable, Value: Encodable>(
        _ value: [Key: Value],
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>
    ) throws {
        try container.encode(value, forKey: key)
    }

    static func safeDecoding<K, Key: Encodable, Value: Encodable>(
        _ value: [Key: Value]?,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>
    ) throws {
        guard let value else { return }

        try safeDecoding(value, forKey: key, container: &container)
    }
}
