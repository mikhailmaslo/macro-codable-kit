import MacroCodableKit

public extension CustomCodingDecoding {
    static func safeDecoding<K, Element: Decodable>(
        _ type: Element.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>
    ) throws -> Element {
    }
}
