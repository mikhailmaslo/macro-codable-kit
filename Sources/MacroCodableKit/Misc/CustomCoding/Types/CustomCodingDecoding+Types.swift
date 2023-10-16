//
//  CustomCodingDecode+Types.swift
//
//
//  Created by Mikhail Maslo on 01.10.23.
//

public extension CustomCodingDecoding {
    // MARK: - Bool

    static func decode<K, Provider>(
        _ type: Bool.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> Bool
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == Bool
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: Bool.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> Bool
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Bool
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: Bool.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> Bool
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Bool,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == Bool
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: - String

    static func decode<K, Provider>(
        _ type: String.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> String
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == String
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: String.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> String
        where Strategy: ValueCodableStrategy,
        Strategy.Value == String
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: String.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> String
        where Strategy: ValueCodableStrategy,
        Strategy.Value == String,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == String
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: - Double

    static func decode<K, Provider>(
        _ type: Double.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> Double
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == Double
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: Double.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> Double where Strategy: ValueCodableStrategy, Strategy.Value == Double {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: Double.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> Double
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Double,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == Double
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: - Float

    static func decode<K, Provider>(
        _ type: Float.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> Float
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == Float
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: Float.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> Float
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Float
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: Float.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> Float
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Float,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == Float
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: - Int

    static func decode<K, Provider>(
        _ type: Int.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> Int
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == Int
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: Int.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> Int
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: Int.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> Int
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == Int
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: - Int8

    static func decode<K, Provider>(
        _ type: Int8.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> Int8
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == Int8
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: Int8.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> Int8
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int8
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: Int8.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> Int8
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int8,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == Int8
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: - Int16

    static func decode<K, Provider>(
        _ type: Int16.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> Int16
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == Int16
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: Int16.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> Int16
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int16
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: Int16.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> Int16
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int16,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == Int16
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: - Int32

    static func decode<K, Provider>(
        _ type: Int32.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> Int32
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == Int32
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: Int32.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> Int32
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int32
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: Int32.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> Int32
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int32,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == Int32
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: - Int64

    static func decode<K, Provider>(
        _ type: Int64.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> Int64
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == Int64
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: Int64.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> Int64
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int64
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: Int64.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> Int64
        where Strategy: ValueCodableStrategy,
        Strategy.Value == Int64,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == Int64
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: - UInt

    static func decode<K, Provider>(
        _ type: UInt.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> UInt
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == UInt
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: UInt.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> UInt
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: UInt.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> UInt
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == UInt
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: - UInt8

    static func decode<K, Provider>(
        _ type: UInt8.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> UInt8
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == UInt8
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: UInt8.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> UInt8
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt8
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: UInt8.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> UInt8
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt8,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == UInt8
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: - UIn16

    static func decode<K, Provider>(
        _ type: UInt16.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> UInt16
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == UInt16
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: UInt16.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> UInt16
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt16
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: UInt16.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> UInt16 where
        Strategy: ValueCodableStrategy,
        Strategy.Value == UInt16,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == UInt16
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: - UInt32

    static func decode<K, Provider>(
        _ type: UInt32.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> UInt32
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == UInt32
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: UInt32.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> UInt32
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt32
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: UInt32.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> UInt32
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt32,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == UInt32
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: - UIn64

    static func decode<K, Provider>(
        _ type: UInt64.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> UInt64
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == UInt64
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, Strategy>(
        _: UInt64.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> UInt64
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt64
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, Provider, Strategy>(
        _ type: UInt64.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> UInt64
        where Strategy: ValueCodableStrategy,
        Strategy.Value == UInt64,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == UInt64
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    // MARK: K: Decodable

    static func decode<K, T, Provider>(
        _ type: T.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider _: Provider.Type
    ) throws -> T
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == T,
        T: Decodable
    {
        do {
            return try container.decode(type, forKey: key)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, T, Provider>(
        _: T.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        provider: Provider.Type
    ) throws -> T.Wrapped?
        where Provider: DefaultValueProvider,
        Provider.DefaultValue == T.Wrapped,
        T: Decodable,
        T: OptionalProtocol
    {
        try decode(T.Wrapped.self, forKey: key, container: container, provider: provider)
    }

    static func decode<K, T, Strategy>(
        _: T.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy _: Strategy.Type
    ) throws -> T
        where Strategy: ValueCodableStrategy,
        Strategy.Value == T
    {
        let valueDecoder = try container.superDecoder(forKey: key)
        return try Strategy.decode(from: valueDecoder)
    }

    static func decode<K, T, Strategy>(
        _: T.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type
    ) throws -> T.Wrapped?
        where Strategy: ValueCodableStrategy,
        Strategy.Value == T.Wrapped,
        T: OptionalProtocol
    {
        if container.contains(key) {
            return try decode(T.Wrapped.self, forKey: key, container: container, strategy: strategy)
        } else {
            return nil
        }
    }

    static func decode<K, T, Provider, Strategy>(
        _ type: T.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider _: Provider.Type
    ) throws -> T
        where Strategy: ValueCodableStrategy,
        Strategy.Value == T,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == T
    {
        do {
            return try decode(type, forKey: key, container: container, strategy: strategy)
        } catch {
            logError(error)

            return Provider.defaultValue
        }
    }

    static func decode<K, T, Provider, Strategy>(
        _: T.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        container: KeyedDecodingContainer<K>,
        strategy: Strategy.Type,
        provider: Provider.Type
    ) throws -> T.Wrapped?
        where Strategy: ValueCodableStrategy,
        Strategy.Value == T.Wrapped,
        Provider: DefaultValueProvider,
        Provider.DefaultValue == T.Wrapped,
        T: OptionalProtocol
    {
        try decode(T.Wrapped.self, forKey: key, container: container, strategy: strategy, provider: provider)
    }
}
