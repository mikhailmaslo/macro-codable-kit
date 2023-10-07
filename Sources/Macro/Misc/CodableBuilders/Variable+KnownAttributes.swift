//
//  Variable+KnownAttribute.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import MacroToolkit

extension Variable {
    func knownAttributes() -> [DefaultCodableBuilders.KnownAttribute: [Any]] {
        var result: [DefaultCodableBuilders.KnownAttribute: [Any]] = [:]
        result.reserveCapacity(attributes.count)
        for attribute in attributes {
            if let omitCoding = attribute.attribute.flatMap({ OmitCoding($0) }) {
                result[.omitCoding, default: []].append(omitCoding)
            } else if let codingKey = attribute.attribute.flatMap({ CodingKey($0) }) {
                result[.codingKey, default: []].append(codingKey)
            } else if let defaultValue = attribute.attribute.flatMap({ DefaultValue($0) }) {
                result[.defaultValue, default: []].append(defaultValue)
            } else if let valueStrategy = attribute.attribute.flatMap({ ValueStrategy($0) }) {
                result[.valueStrategy, default: []].append(valueStrategy)
            } else if let customCoding = attribute.attribute.flatMap({ CustomCoding($0) }) {
                result[.customCoding, default: []].append(customCoding)
            } else {
                // ignore unknown attributes
            }
        }
        return result
    }
}
