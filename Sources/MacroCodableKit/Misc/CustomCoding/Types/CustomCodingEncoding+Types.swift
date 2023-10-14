//
//  CustomCodingEncoding.swift
//
//
//  Created by Mikhail Maslo on 03.10.23.
//

public extension CustomCodingEncoding {
    // MARK: - Bool

    static func encode<K, Strategy>(
        _ value: Bool,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Bool
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - String

    static func encode<K, Strategy>(
        _ value: String,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == String
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - Double

    static func encode<K, Strategy>(
        _ value: Double,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Double
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - Float

    static func encode<K, Strategy>(
        _ value: Float,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Float
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - Int

    static func encode<K, Strategy>(
        _ value: Int,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - Int8

    static func encode<K, Strategy>(
        _ value: Int8,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int8
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - Int16

    static func encode<K, Strategy>(
        _ value: Int16,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int16
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - Int32

    static func encode<K, Strategy>(
        _ value: Int32,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int32
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - Int64

    static func encode<K, Strategy>(
        _ value: Int64,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int64
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - UInt

    static func encode<K, Strategy>(
        _ value: UInt,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - UInt8

    static func encode<K, Strategy>(
        _ value: UInt8,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt8
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - UInt16

    static func encode<K, Strategy>(
        _ value: UInt16,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt16
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - UInt32

    static func encode<K, Strategy>(
        _ value: UInt32,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt32
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - UInt64

    static func encode<K, Strategy>(
        _ value: UInt64,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt64
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    // MARK: - K: Encodable

    static func encode<K, T, Strategy>(
        _ value: T,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == T
    {
        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: value, to: encoder)
    }

    static func encode<K, T, Strategy>(
        _ value: T,
        forKey key: KeyedEncodingContainer<K>.Key,
        container: inout KeyedEncodingContainer<K>,
        strategy: Strategy.Type
    ) throws
        where Strategy: ValueCodableStrategy,
        Strategy.Value == T.Wrapped,
        T: OptionalProtocol
    {
        guard let unwrappedValue = value.asOptional() else { return }

        let encoder = container.superEncoder(forKey: key)
        try strategy.encode(value: unwrappedValue, to: encoder)
    }
}
