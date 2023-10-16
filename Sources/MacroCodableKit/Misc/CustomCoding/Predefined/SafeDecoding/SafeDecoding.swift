//
//  SafeDecoding.swift
//
//
//  Created by Mikhail Maslo on 04.10.23.
//

/// Decodes arrays and dictionaries in a safe manner, while gracefully handling decoding errors during the process
///
/// ``SafeDecoding`` provides a robust way to decode collections, ensuring that decodable elements are captured and errors are logged for further inspection. Suppressed errors are transfered to ``CustomCodingDecoding/logError(_:)``
///
/// To utilize this strategy, annotate the property with ``CustomCoding(_:)`` passing ``SafeDecoding``. Ensure the parent type is annotated with one of  ``Codable()`` or ``Decodable()``.
///
/// - ``SafeDecoding`` with Arrays:
///     - **Usage**:
///         ```swift
///         @Codable
///         struct ArrayExample: Equatable {
///             @CustomCoding(SafeDecoding)
///             var elements: [Element]
///         }
///         ```
///     - **Decoding** ``CustomCodingDecoding/safeDecoding(_:forKey:container:)-1qnwn`` or ``CustomCodingDecoding/safeDecoding(_:forKey:container:)-3ytig`` for optional
///     - **Encoding**: Follows the standard encoding process for arrays, see``CustomCodingEncoding/safeDecoding(_:forKey:container:)-7cwmw`` and ``CustomCodingEncoding/safeDecoding(_:forKey:container:)-7cwmw`` for more details
///
/// - ``SafeDecoding`` with Dictionary:
///     - supports custom [`JSONDecoder.KeyDecodingStrategy`](https://developer.apple.com/documentation/foundation/jsondecoder/keydecodingstrategy)
///     - only handles keys of type [`String`](https://developer.apple.com/documentation/swift/string) or [`Int`](https://developer.apple.com/documentation/swift/int)
///     - **Usage**:
///         ```swift
///         @Codable
///         struct DictionaryExample: Equatable {
///             @CustomCoding(SafeDecoding)
///             var entries: [String: Element]
///         }
///         ```
///     - **Decoding** ``CustomCodingDecoding/safeDecoding(_:forKey:container:)-5nus0`` and ``CustomCodingDecoding/safeDecoding(_:forKey:container:)-9nz0q`` for optional
///     - **Encoding**: Follows the standard encoding process for dictionaries, see ``CustomCodingEncoding/safeDecoding(_:forKey:container:)-5sgwu`` and ``CustomCodingEncoding/safeDecoding(_:forKey:container:)-54c5h`` for more details
public struct SafeDecoding: CustomDecodingName {}
