//
//  CodingKeysBuilder+Enum.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import MacroToolkit

extension CodingKeysBuilder {
    static func verify(
        accessModifier: AccessModifier?,
        enumDecl: Enum
    ) throws -> CodingKeysBuilder.BuildingData {
        CodingKeysBuilder.BuildingData(
            accessModifier: accessModifier,
            items: enumDecl.cases.map { CodingKeysBuilder.BuildingData.Item(identifier: $0.identifier, customCodingKey: nil) }
        )
    }
}
