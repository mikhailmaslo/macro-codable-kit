import MacroCodableKit

public extension CustomCodingEncoding {
    static func omitEmpty<K, Element: Encodable>(
        _ value: Element,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>
    ) throws {
        if (value as? OmitEmptyCheckable)?.omitEmpty_isEmpty != true {
            try container.encode(value, forKey: key)
        }
    }

    static func omitEmpty<K, Element: Encodable>(
        _ value: Element?,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>
    ) throws {
        try container.encodeIfPresent(value, forKey: key)
    }
}
