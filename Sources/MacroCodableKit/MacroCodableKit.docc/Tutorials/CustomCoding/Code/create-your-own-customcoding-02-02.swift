import MacroCodableKit

public extension CustomCodingEncoding {
    static func omitEmpty<K, Element: Encodable>(
        _ value: Element,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>
    ) throws {
    }
}
