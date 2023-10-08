//
//  DefaultCodableBuilders.CodingKeysBuilder.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import MacroToolkit

struct CodingKeysBuilder: CodeBuildable {
    struct BuildingData {
        struct Item {
            let identifier: String
            let customCodingKey: String?
        }

        let accessModifier: AccessModifier?
        let items: [Item]
    }

    private let buildingData: BuildingData

    init(buildingData: BuildingData) {
        self.buildingData = buildingData
    }

    func build() -> String {
        CodeBuilders.content {
            if buildingData.items.isEmpty {
                ""
            } else {
                DeclarationBuilder(
                    accessModifier: buildingData.accessModifier,
                    signature: "enum CodingKeys: String, CodingKey"
                ) {
                    buildingData.items.map { item in
                        "case \(item.identifier)" + (item.customCodingKey.map { " = \"\($0)\"" } ?? "")
                    }
                }
            }
        }.build()
    }
}
