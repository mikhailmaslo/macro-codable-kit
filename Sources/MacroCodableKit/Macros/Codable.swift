//
//  Codable.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

/**
 A suite of macros designed to facilitate the conformance of types to the `Codable` protocol, streamlining the encoding and decoding processes. These macros are highly customizable, allowing for tailored encoding and decoding behaviors to meet specific requirements.

 Here are the key features and customizable components associated with these macros:

 - **Custom Error Handling**:
    - Utilizes `CustomCodingDecoding.errorHandler` and `CustomCodingEncoding.errorHandler` for centralized error handling during the decoding and encoding processes respectively.
    - These handlers capture and manage errors, enabling robust error logging and management.

 - **Customizable Annotations**:
    These annotations can be used to modify the default encoding and decoding behaviors:

    - `CodingKey`: Changes the default `codingKey` of a property to a specified key, altering how the property is encoded and decoded.

    - `OmitCoding`: Ignores a property during encoding and decoding processes, effectively excluding it from being processed.

    - `DefaultValue`: Provides a default value for a property when decoding, useful in cases where the decoded data might lack certain values.

    - `ValueStrategy`: Provides custom encodable and decodable strategies for a particular property.

    - `CustomCoding`: Allows for customized encoding and decoding strategies, particularly useful for complex or non-standard data handling.

 - **Usage**:
    Apply the `@Codable` macro to a type to automatically generate conformances to `Decodable` and `Encodable` protocols. Further, utilize the aforementioned annotations to modify the default behavior to meet specific requirements.

    ```swift
    @Codable
    struct Example {
        @CodingKey("custom_key")
        var property: String
    }
    ```

    In this example, `@Codable` macro is used to make `Example` struct conform to `Codable` protocol, and `@CodingKey` annotation changes the coding key for `property` to "custom_key".

 - **Note**:
    -  The `@Codable` macro suite is designed to work seamlessly with the custom encoding and decoding strategies provided by `CustomCodingDecoding` and `CustomCodingEncoding`, making it a powerful tool for managing complex encoding and decoding requirements in a straightforward and efficient manner.
    - If a type already conforms to `Decodable`, no additional `Decodable` conformance will be generated.
    - If a type already conforms to `Encodable`, no additional `Encodable` conformance will be generated.

 - **See Also**:
    - `CodingKey`
    - `OmitCoding`
    - `DefaultValue`
    - `ValueStrategy`
    - `CustomCoding`
    - `CustomCodingDecoding`
    - `CustomCodingEncoding`
    - `SafeDecoding`
 */
@attached(extension, conformances: Decodable, Encodable, names: named(CodingKeys), named(init(from:)), named(encode(to:)))
public macro Codable() = #externalMacro(module: "Macro", type: "CodableMacro")

/**
 A macro designed to extend types to conform to the `Decodable` protocol effortlessly, while allowing for a degree of customization to cater to specific decoding requirements. The usage and behavior of annotations are analogous to the `@Codable` macro but exclusively geared towards decoding.

 - **Features**:
    - Leverages `CustomCodingDecoding.errorHandler` for centralized error handling during the decoding process.
    - Utilizes customizable annotations such as `CodingKey`, `OmitCoding`, `DefaultValue`, `ValueStrategy`, or `CustomCoding` to modify the default decoding behavior.

 - **Usage**:
    Apply the `@Decodable` macro to a type to automatically generate conformance to the `Decodable` protocol.

    ```swift
    @Decodable
    struct Example {
        @CodingKey("custom_key")
        var property: String
    }
    ```

 - **Note**:
    - If a type already conforms to `Decodable`, no additional `Decodable` conformance will be generated.
    - For more extensive documentation, refer to the `@Codable` macro documentation.

 - **See Also**:
    - `@Codable` Macro
    - `CustomCodingDecoding`
 */
@attached(extension, conformances: Decodable, names: named(CodingKeys), named(init(from:)))
public macro Decodable() = #externalMacro(module: "Macro", type: "DecodableMacro")

/**
 A macro tailored to extend types to conform to the `Encodable` protocol, with a provision for customization to cater to specific encoding requirements. The usage and behavior of annotations are analogous to the `@Codable` macro but exclusively geared towards encoding.

 - **Features**:
    - Utilizes `CustomCodingEncoding.errorHandler` for centralized error handling during the encoding process.
    - Utilizes customizable annotations such as `CodingKey`, `OmitCoding`, `DefaultValue`, `ValueStrategy`, or `CustomCoding` to modify the default encoding behavior.

 - **Usage**:
    Apply the `@Encodable` macro to a type to automatically generate conformance to the `Encodable` protocol.

    ```swift
    @Encodable
    struct Example {
        @CodingKey("custom_key")
        var property: String
    }
    ```

 - **Note**:
    - If a type already conforms to `Encodable`, no additional `Encodable` conformance will be generated.
    - For more extensive documentation, refer to the `@Codable` macro documentation.

 - **See Also**:
    - `@Codable` Macro
    - `CustomCodingEncoding`
 */
@attached(extension, conformances: Encodable, names: named(CodingKeys), named(encode(to:)))
public macro Encodable() = #externalMacro(module: "Macro", type: "EncodableMacro")
