//
//  CodingKeysBuilder+Instance.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import MacroToolkit

extension CodingKeysBuilder {
    static func verify(
        accessModifier: AccessModifier?,
        instance: Instance
    ) throws -> CodingKeysBuilder.BuildingData {
        CodingKeysBuilder.BuildingData(
            accessModifier: accessModifier,
            items: try instance.members
                .compactMap { member -> CodingKeysBuilder.BuildingData.Item? in
                    guard
                        let variable = member.asVariable,
                        !variable.isStatic
                    else {
                        return nil
                    }

                    let knownAttributes = variable.knownAttributes()
                    try variable.verify(knownAttributes)

                    guard variable.isStoredProperty else {
                        return nil
                    }

                    // Skip coding if omitCoding is specified
                    guard knownAttributes[.omitCoding] == nil else {
                        return nil
                    }

                    guard
                        let binding = variable.bindings.first,
                        let identifier = binding.identifier
                    else {
                        assertionFailure("`Variable.verify(...)` should've caught it")
                        return nil
                    }

                    return CodingKeysBuilder.BuildingData.Item(
                        identifier: identifier,
                        customCodingKey: (knownAttributes[.codingKey]?.first as? CodingKey)?.key
                    )
                }
        )
    }
}
