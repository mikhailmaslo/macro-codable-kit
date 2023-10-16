import MacroCodableKit

public extension CustomCodingDecoding {
    static func safeDecoding<K, Element: Decodable>(
        _ type: Element.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>
    ) throws -> Element {
        try container.decode(type, forKey: key)
    }

    static func safeDecoding<K, Element: Decodable>(
        _ type: Element?.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>
    ) throws -> Element {
        try container.decodeIfPresent(type, forKey: key)
    }
}
