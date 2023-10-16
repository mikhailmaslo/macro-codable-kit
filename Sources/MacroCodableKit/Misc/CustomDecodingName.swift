//
//  CustomDecodingName.swift
//
//
//  Created by Mikhail Maslo on 03.10.23.
//

/// A marker protocol providing types in ``CustomCoding(_:)``
///
/// A marker protocol used to specify the name of custom encoding and decoding functions. Types conforming to this protocol don't functionally do anything, but their names are used to derive the name of custom functions in ``CustomCodingDecoding`` and ``CustomCodingEncoding`` namespaces.
public protocol CustomDecodingName {}
