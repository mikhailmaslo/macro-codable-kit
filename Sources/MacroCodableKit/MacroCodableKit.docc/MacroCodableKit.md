# ``MacroCodableKit``

Conform to `Codable`, adjust coding strategy, and implement OpenAPI spec with ease

## Overview

**MacroCodableKit** is a comprehensive solution to conform to [Codable](https://developer.apple.com/documentation/swift/codable), which leverages [Swift Macros](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/) under the hood, thus providing flexible coding customizations.

To start, add a simple ``Codable()`` annotation next to a struct. Or use ``Decodable()`` or ``Encodable()``, if you need only `Decodable` or `Encodable` accordingly.

Adjust default [CodingKeys](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types#2904057) with ``CodingKey(_:)`` or skip a property entiraly from coding using ``OmitCoding()``.

Perform custom coding with ``ValueStrategy(_:)`` to use your or a build-in coding strategy. For example, you might need to map a timestamps to a Date and you can do it with build-in ``TimestampedDate`` strategy. Or you might want to use a default value if decoding fails and ``DefaultValue(_:)`` is here to the rescue.

## Topics

### Coding

- ``Codable()``

### Annotations

- ``DefaultValue(_:)``
- ``ValueStrategy(_:)``
- ``CustomCoding(_:)``

### OpenAPI coding

- ``OneOfCodable()``
- ``AllOfCodable()``

### Under the hood

- ``CustomCodingDecoding``
- ``CustomCodingEncoding``
