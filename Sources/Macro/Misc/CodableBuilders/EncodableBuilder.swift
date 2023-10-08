//
//  DefaultCodableBuilders.EncodableBuilder.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import MacroToolkit

struct EncodableBuilder: CodeBuildable {
    struct BuildingData {
        struct Item {
            let identifier: String
            let function: String
        }

        let accessModifier: AccessModifier?
        let strategy: CodableStrategy
        let items: [Item]
    }

    private let buildingData: BuildingData

    init(buildingData: BuildingData) {
        self.buildingData = buildingData
    }

    func build() -> String {
        DeclarationBuilder(accessModifier: buildingData.accessModifier, signature: "func encode(to encoder: Encoder) throws") {
            if buildingData.items.isEmpty {
                ""
            } else {
                switch buildingData.strategy {
                case .singleValue:
                    ""
                case .codingKeys:
                    "var container = encoder.container(keyedBy: CodingKeys.self)"
                }

                buildingData.items
                    .map { item in
                        item.function
                    }
            }
        }.build()
    }
}
