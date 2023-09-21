//
//  Annotations.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

/**
 An annotation that attaches a `CodingKey` macro to a property.
 Will change the default codingKey of a property to the specified `key`.
 Will have effect only with one of `Codable`, `Decodable`, or `Encodable` macros.

 - Note: This annotation is attached to properties within the types being modified by the `Codable`, `Decodable`, or `Encodable` macros.
 */
@attached(peer)
public macro CodingKey(_ key: String) = #externalMacro(module: "Macro", type: "CodingKeyMacro")

/**
 An annotation that attaches an `OmitCoding` macro to a property.
 Ignores a property in Encoding and Decoding.
 Will have effect only with one of `Codable`, `Decodable`, or `Encodable` macros.

 - Note: This annotation is attached to properties within the types being modified by the `Codable`, `Decodable`, or `Encodable` macros.
 */
@attached(peer)
public macro OmitCoding() = #externalMacro(module: "Macro", type: "OmitCodingMacro")

/**
 An annotation that attaches a `DefaultValue` macro to a property.
 If a value is decoded with an error, the `DefaultValue` annotation will return the default value provided by the `DefaultValueProvider`.
 This annotation has no effect on encoding.

 During decoding, any non-thrown errors encountered will be sent to `CustomCodingDecoding.errorHandler`, allowing for custom error handling.

 - Note:
   - This annotation is attached to properties within the types being modified by the `Codable`, `Decodable`, or `Encodable` macros.

 - SeeAlso:
   - `CustomCodingDecoding`
 */
@attached(peer)
public macro DefaultValue<Provider: DefaultValueProvider>(
    _ type: Provider.Type
) = #externalMacro(module: "Macro", type: "DefaultValueMacro")

/**
 An annotation that attaches a `ValueStrategy` macro to a property, allowing for custom encoding and decoding strategies as defined by a `ValueCodableStrategy`.

 This annotation can be used in conjunction with the `DefaultValue` annotation. If decoding with the provided strategy fails, then the default value will be used.

 During encoding and decoding, any non-thrown errors encountered will be sent to `CustomCodingEncoding.errorHandler` or `CustomCodingDecoding.errorHandler` respectively, allowing for custom error handling.

 - Note:
   - This annotation is attached to properties within the types being modified by the `Codable`, `Decodable`, or `Encodable` macros.
   - The custom strategy is defined by implementing the `ValueCodableStrategy` protocol.

 - SeeAlso:
   - `CustomCodingDecoding`
   - `CustomCodingEncoding`
 */
@attached(peer)
public macro ValueStrategy<Strategy: ValueCodableStrategy>(
    _ strategy: Strategy.Type
) = #externalMacro(module: "Macro", type: "ValueStrategyMacro")

/**
 An annotation that attaches a `CustomCoding` macro to a property, enabling custom encoding and decoding strategies. This macro modifies the generated `Codable` conformance, redirecting the encoding and decoding of the annotated property to custom functions.

 The name of the custom functions is derived from the name of the type passed to the `CustomCoding` annotation. For instance, `@CustomCoding(SafeDecoding)` directs the `@Codable` macro to use the `SafeDecoding` function in `CustomCodingDecoding` and `CustomCodingEncoding` for decoding and encoding respectively.

 - Built-in Examples:
   - `SafeDecoding`: A custom decoding strategy that safely handles decoding errors for arrays and dictionaries.

 - Note:
   - This annotation is attached to properties within the types being modified by the `Codable`, `Decodable`, or `Encodable` macros.
   - Implementations in `CustomCodingDecoding` and `CustomCodingEncoding` are required.

 - Example:
    ```swift
    @Codable
    struct ArrayExample: Equatable {
        @CustomCoding(SafeDecoding)
        var elements: [Element]
    }
    // The `@CustomCoding(SafeDecoding)` annotation directs the `@Codable` macro to use the `SafeDecoding` function in `CustomCodingDecoding` and `CustomCodingEncoding` for decoding and encoding respectively.
    ```

 - Step-by-Step Guide to Create Your Own `CustomCoding`:
   1. Define a type conforming to `CustomDecodingName`:
      ```swift
      struct YourCustomName: CustomDecodingName {}
      ```
   2. Implement the required functions in `CustomCodingDecoding`:
      ```swift
      public extension CustomCodingDecoding {
          static func yourCustomName<K, Element: Decodable>(
              _ type: Element.Type,
              forKey key: KeyedDecodingContainer<K>.Key,
              container: KeyedDecodingContainer<K>
          ) throws -> Element { ... }

          // For decoding optionals:
          static func yourCustomName<K, Element: Decodable>(
              _: Element?.Type,
              forKey key: KeyedDecodingContainer<K>.Key,
              container: KeyedDecodingContainer<K>
          ) throws -> Element? { ... }
      }
      ```
   3. Implement the required functions in `CustomCodingEncoding`:
      ```swift
      public extension CustomCodingEncoding {
          static func yourCustomName<K, Element: Encodable>(
              _ value: Element,
              forKey key: KeyedEncodingContainer<K>.Key,
              container: inout KeyedEncodingContainer<K>
          ) throws { ... }

          // For decoding optionals:
          static func yourCustomName<K, Element: Decodable>(
              _ value: Element?,
              forKey key: KeyedDecodingContainer<K>.Key,
              container: KeyedDecodingContainer<K>
         ) throws { ... }
      }
      ```
   4. Use your custom coding strategy:
      ```swift
      @Codable
      struct YourStruct: Equatable {
          @CustomCoding(YourCustomName)
          var yourProperty: YourType
      }
      ```

 - SeeAlso:
   - `CustomCodingDecoding`
   - `CustomCodingEncoding`
   - `CustomDecodingName`
 */
@attached(peer)
public macro CustomCoding<Name: CustomDecodingName>(
    _ name: Name.Type
) = #externalMacro(module: "Macro", type: "CustomCodingMacro")
