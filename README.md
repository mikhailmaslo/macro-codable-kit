# MacroCodableKit

**MacroCodableKit** enhances your `Codable` experience in Swift, leveraging macros to generate precise and efficient code with zero additional memory allocations, thanks to the usage of pure (static) functions. It's a comprehensive solution providing support for `AllOf`, `OneOf`, and customizable `CodingKeys`, extending the native Codable capabilities to keep up with OpenAPI specification seamlessly.

## Table of Contents

- [MacroCodableKit](#macrocodablekit)
- [Table of Contents](#table-of-contents)
- [Motivation](#motivation)
- [Features](#features)
- [Usage](#usage)
  - [Basics - @Codable](#basics---codable)
  - [@AllOfCodable](#allofcodable)
  - [@OneOfCodable](#oneofcodable)
  - [Annotations](#annotations)
    - [@CodingKey](#codingkey)
    - [@OmitCoding](#omitcoding)
    - [@DefaultValue](#defaultvalue)
    - [@ValueCodable](#valuecodable)
    - [@CustomCoding](#customcoding)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
- [Acknowledgments](#acknowledgments)

## Motivation

Codable with property wrappers is an alternative way to approach `Codable`, it's quite a flexible approach and surely greatly reduces amount of boilerplate, at the same time it has its limitations

- You can't implement things like `OneOf` or `AllOf` from [OpenAPI](https://spec.openapis.org/oas/v3.1.0) which is quite common in nowdays APIs
- You can't alter `CodingKeys` with `@propertyWrapper`
- `@propertyWrapper` is an additional struct next to a property, so you might endup with twice as much allocations then needed
- `@propertyWrapper` should be settable, so you can't use `let` and you'll probably endup with `private(set)`
> There is a [proposal](https://github.com/apple/swift-evolution/pull/1910) though to allow `let` for `@propertyWrappers` which I hope will be eventually completed

Approaching `Codable` with [Macros](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/) allows zero additional allocation, immutable properties, and the implementation of any desirable Codable strategy inside one tool - **MacroCodableKit**, which provides `OneOf` and `AllOf` coding implementations from OpenAPI spec, and allows `CodingKeys` altering via annotations.

## Features

- **OpenAPI Compatibility**: Embrace OpenAPI specifications with [@OneOfCodable](#oneofcodable), [@AllOfCodable](#allofcodable) with ease.
- **Custom Coding Keys**: Specify custom coding keys with `CodingKey(_ key: String)` annotation.
- **Skip Coding of a Property**: Opt to ignore certain properties from being coded with `OmitCoding`.
- **Default Values and Strategies**: Use [@DefaultValue](#defaultvalue) to handle failed decoding gracefully or [@ValueStrategy](#valuestrategy) to decode values your way, such as handling dates in various formats.
- **Custom Coding Strategies**: Utilize [@CustomCoding](#customcoding) to define your encoding and decoding logic. Use build-in `SafeDecoding` to handle arrays and dictionaries in a safe manner.
- **Error Handling**: Handle ignored decoding errors with `CustomCodingDecoding.errorHandler` & encoding errors with `CustomCodingEncoding.errorHandler`.
- **Zero additional allocations**: Coding is done by predefined clean (static) functions, so there's no need to allocate additional memory

... and more!

## Usage

### Basics - @Codable

Annotate a struct with `@Codable`, without additional annotations on properties it will generate default `Codable` conformance

> **Note**
> Do not conform to `Codable` protocol yourself, it will prevent macro from generating code

```swift
@Codable
struct User {
    let birthday: Double
    let name: String
    let isVerified: Bool
}
```

Let's convert `birthday` to `Date`, change coding key of `isVerified` and make it default to `false`

> **Note**
> Conform only to `@Decodable` if you don't need encoding

```swift
@Decodable
struct User {
    @ValueStrategy(ISO8601Default)
    let birthday: Date
    let name: String

    @CodingKey("is_verified")
    @DefaultValue(BoolFalse)
    let isVerified: Bool
}

// json: { "birthday": 1696291200.0, "name": "Mikhail" }
// is_verified is not specified, so the default value is "false" as specified by `@DefaultValue`
```

### @AllOfCodable

@AllOfCodable describes [OpenAPI AllOf](https://spec.openapis.org/oas/v3.1.0#composition-and-inheritance-polymorphism) relationship

Imagine you have `SocialUser` OpenAPI specification which inherits from `User` and have additional properties

```yaml
SocialUser:
  allOf:
    - $ref: '#components/schema/User'
    - type: object
      properties:
        username:
          type: string
        isPublic:
          type: boolean
```

In Swift code it could be implemented with just `AllOfCodable` annotation
```swift
@AllOfCodable
struct SocialUser {
  struct Properties: Codable {
    let isPublic: Bool
    let username: String
  }
  let user: User
  let additionalProperties: Properties
}
```

### @OneOfCodable

`@OneOfCodable` describes [OpenAPI OneOf](https://spec.openapis.org/oas/v3.1.0#fixed-fields-20) relationship

> **Note**
> Only one associated value is expected in each enum case

```swift
@OneOfCodable
enum PaymentMethod {
  case card(DebitCardPayload)
  case applePay(ApplePayPayload)
}
// json: either { "card": { ... DebitCardPayload ... } } or { "applePay": { ... ApplePayPayload ... } }
```

### Annotations

#### @CodingKey

Annotate a property with `@CodingKey(_ key: String)`, key will be used as CodingKey in decoding and encoding
```swift
struct User {
  @CodingKey("is_verified")
  let isVerified: Bool
}
```

#### @OmitCoding

Skip coding for a specific property with `@OmitCoding()` annotation

```swift
struct User {
  @OmitCoding()
  let isVerified: Bool
}
```

It might be useful when you describe an object, where each encoded property is a part of a http request body
```swift
@Encodable
struct Request {
  var endpoint: String { "/user/\(userID)/follow" }

  // We don't want to encode userID, since it's not part of the request body
  @OmitCoding
  let userID: String
  
  let isFollowing: Bool
}
```

#### @DefaultValue

Use `@DefaultValue<Provider: DefaultValueProvider>(_ type: Provider.Type)` to provide default value if decoding fails

> **Warning**
> `@DefaultValue(_:)` doesn't affect encoding

```swift
@Codable
struct User {
  @DefaultValue(BoolFalse) // property will be `false`, if value is absent or decoding fails
  let isVerified: Bool
}
```

Build-in presets:
- **BoolTrue** - true by default, **BoolFalse** - false by default
- **IntZero** - Int(0) by default
- **DoubleZero** - Double(0) by default

#### @ValueCodable

Use `@ValueStrategy<Strategy: ValueCodableStrategy>(_ strategy: Strategy.Type)` to provide custom mapping

```swift
@Encodable
struct Upload {
    @ValueStrategy(Base64Data)
    let document: Data
}
```

Can be combined with [DefaultValue](#DefaultValue)

```swift
@Decodable
struct Example {
    @ValueStrategy(SomeStringStrategy)
    @DefaultValue(EmptyString)
    let string: String
}
```

Build-in presets
- Dates:
  - ISO8601Default - handles dates in ISO8601 format, for example, `2023-10-03T10:15:30+00:00`
  - ISO8601WithFullDate - handles dates with the full date in ISO8601 format, for example, `2023-10-03`
  - ISO8601WithFractionalSeconds - handles dates with fractional seconds in ISO8601 format, for example, `2023-10-03T10:15:30.123+00:00`
  - YearMonthDayDate - handles dates with full date, example: `2023-10-03`
  - RFC2822Date - handles dates in "EEE, d MMM y HH:mm:ss zzz" (RFC2822), example: `Tue, 3 Oct 2023 10:15:30 GMT`
  - RFC3339Date - handles dates in "yyyy-MM-dd'T'HH:mm:ssZ" (RFC2822), example: `2023-10-03T10:15:30Z`
  - TimestampedDate - converts timestamp either `String` or `Double` to `Date`, example: `1696291200.0`
- Misc:
  - Base64Data - converts base64 string to Data

#### @CustomCoding

`@CustomCoding` annotation allows specifying custom encoding and decoding strategies for properties. Attach it to a property and specify a type that contains the custom encoding/decoding logic. For instance, `@CustomCoding(SafeDecoding)` uses `safeDecoding` functions from `CustomCodingDecoding` and `CustomCodingEncoding` for handling arrays and dictionaries safely during encoding and decoding.

```swift
@Codable
struct TaggedPhotos: Equatable {
    @CustomCoding(SafeDecoding)
    var photos: [Photo]
}

@Codable
struct UserProfiles: Equatable {
    @CustomCoding(SafeDecoding)
    var profiles: [String: Profile]
}

// Corresponding JSON for TaggedPhotos with corrupted data
// {
//     "photos": [
//         { "url": "https://example.com/photo1.jpg", "tag": "vacation" },
//         { "url": "https://example.com/photo2.jpg", "tag": "family" },
//         "corruptedData"
//     ]
// }

// Corresponding JSON for UserProfiles with corrupted data
// {
//     "profiles": {
//         "john_doe": { "age": 25, "location": "NYC" },
//         "jane_doe": { "age": 28, "location": "LA" },
//         "corrupted_entry": "corruptedData"
//     }
// }
```

In the example above, `@CustomCoding(SafeDecoding)` will catch and forward any decoding errors caused by invalid decoding to `CustomCodingDecoding.errorHandler`, allowing the rest of the data to be decoded safely.

## Installation

### Swift Package Manager

## Acknowledgments

- **[swift-foundation](https://github.com/apple/swift-foundation)** by **Apple Swift Foundation Team** provided a profound understanding of `Decoder`, `Encoder`, and the handling of `encodeIfPresent` and `decodeIfPresent` functions which logic is required for the library such as **MacroCodableKit**.

- **[BetterCodable](https://github.com/marksands/BetterCodable)** by [Mark Sands](https://github.com/marksands): This project has all the common and widespread use cases for `Codable`, which was adopted in **MacroCodableKit**. Especially [key conversion case](https://github.com/marksands/BetterCodable/pull/51) which turned out to be vital for `SafeDecoding` on dictionaries
