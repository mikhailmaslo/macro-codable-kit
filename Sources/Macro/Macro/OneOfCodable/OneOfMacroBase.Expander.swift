//
//  OneOfMacroBase.Expander.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

import MacroToolkit
import SwiftSyntax

extension OneOfMacroBase {
    final class Expander {
        func verify(
            declaration: some DeclGroupSyntax,
            conformances: Set<Conformance>
        ) throws -> CodableBuildingData {
            guard let enumDecl = Enum(declaration) else {
                MacroConfiguration.current.context.diagnose(
                    Diagnostic.requiresEnum.diagnose(at: declaration)
                )

                throw CommonError.diagnosticError
            }

            let accessModifier: AccessModifier? = enumDecl.isPublic ? .public : nil
            let codingKeysBuildingData = try CodingKeysBuilder.verify(
                accessModifier: accessModifier,
                enumDecl: enumDecl
            )

            let encodingBuildingData: EncodableBuilder.BuildingData?
            if conformances.contains(.Encodable) {
                encodingBuildingData = try EncodableBuilder.verify(
                    accessModifier: accessModifier,
                    enumDecl: enumDecl
                )
            } else {
                encodingBuildingData = nil
            }

            let decodingBuildingData: DecodableBuilder.BuildingData?
            if conformances.contains(.Decodable) {
                decodingBuildingData = try DecodableBuilder.verify(
                    accessModifier: accessModifier,
                    enumDecl: enumDecl
                )
            } else {
                decodingBuildingData = nil
            }

            return CodableBuildingData(
                codingKeysBuildingData: codingKeysBuildingData,
                encodingBuildingData: encodingBuildingData,
                decodingBuildingData: decodingBuildingData
            )
        }

        func extensionCodeBuilder(
            type: some TypeSyntaxProtocol,
            buildingData: CodableBuildingData,
            conformances: Set<Conformance>
        ) -> CodeBuildable {
            CodeBuilders.content {
                if !conformances.isEmpty {
                    CodeBuilders.extensionBuilder(
                        accessModifier: nil,
                        name: type.trimmedDescription,
                        conformances: conformances
                    ) { [self] in
                        membersCodeBuilder(buildingData: buildingData)
                    }
                }
            }
        }

        func membersCodeBuilder(
            buildingData: CodableBuildingData
        ) -> CodeBuildable {
            CodeBuilders.content { [self] in
                if let buildingData = buildingData.codingKeysBuildingData {
                    CodingKeysBuilder(buildingData: buildingData)
                }

                if let buildingData = buildingData.decodingBuildingData {
                    decoder(buildingData: buildingData)
                }

                if let buildingData = buildingData.encodingBuildingData {
                    encoder(buildingData: buildingData)
                }
            }
        }

        private func decoder(buildingData: DecodableBuilder.BuildingData) -> some CodeBuildable {
            CodeBuilders.decoder(accessModifier: buildingData.accessModifier) {
                if buildingData.items.isEmpty {
                    ""
                } else {
                    "let container = try decoder.container(keyedBy: CodingKeys.self)"

                    """
                    guard let key = container.allKeys.first else {
                        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case."))
                    }
                    """

                    SwitchBuilder(expression: "key") {
                        buildingData.items.map { item in
                            """
                            case .\(item.identifier):
                                self = \(item.function)
                            """
                        }
                    }
                }
            }
        }

        private func encoder(buildingData: EncodableBuilder.BuildingData) -> some CodeBuildable {
            CodeBuilders.encoder(accessModifier: buildingData.accessModifier) {
                if buildingData.items.isEmpty {
                    ""
                } else {
                    "var container = encoder.container(keyedBy: CodingKeys.self)"

                    SwitchBuilder(expression: "self") {
                        buildingData.items.map { item in
                            """
                            case .\(item.identifier)(let payload):
                                \(item.function)
                            """
                        }
                    }
                }
            }
        }

        func generateAndFormat(codeBuilder: CodeBuildable) throws -> String {
            try codeBuilder.build().swiftFormatted
        }

        func mapToExtensionDeclSyntax(code: String) -> ExtensionDeclSyntax? {
            DeclSyntax(stringLiteral: code).as(ExtensionDeclSyntax.self)
        }
    }
}

extension EncodableBuilder {
    static func verify(
        accessModifier: AccessModifier?,
        enumDecl: Enum
    ) throws -> EncodableBuilder.BuildingData {
        try EncodableBuilder.BuildingData(
            accessModifier: accessModifier,
            strategy: .codingKeys,
            items: enumDecl.cases
                .compactMap { enumCase -> EncodableBuilder.BuildingData.Item? in
                    guard
                        case let .associatedValue(parameters) = enumCase.value,
                        parameters.count == 1,
                        let parameter = parameters.first
                    else {
                        MacroConfiguration.current.context.diagnose(
                            OneOfMacroBase.Diagnostic.requiresAssociatedValue
                                .diagnose(at: enumCase._syntax)
                        )
                        throw CommonError.diagnosticError
                    }

                    let functionName = parameter.type.isOptional ? "encodeIfPresent" : "encode"
                    return EncodableBuilder.BuildingData.Item(
                        identifier: enumCase.identifier,
                        function: "try container.\(functionName)(payload, forKey: .\(enumCase.identifier))"
                    )
                }
        )
    }
}

extension DecodableBuilder {
    static func verify(
        accessModifier: AccessModifier?,
        enumDecl: Enum
    ) throws -> DecodableBuilder.BuildingData {
        return try DecodableBuilder.BuildingData(
            accessModifier: accessModifier,
            strategy: .codingKeys,
            items: enumDecl.cases
                .compactMap { enumCase -> DecodableBuilder.BuildingData.Item? in
                    guard
                        case let .associatedValue(parameters) = enumCase.value,
                        parameters.count == 1,
                        let parameter = parameters.first
                    else {
                        MacroConfiguration.current.context.diagnose(
                            OneOfMacroBase.Diagnostic.requiresAssociatedValue
                                .diagnose(at: enumCase._syntax)
                        )
                        throw CommonError.diagnosticError
                    }

                    let typeDescription = parameter.type.typeDescription(preservingOptional: false)
                    let functionName = parameter.type.isOptional ? "decodeIfPresent" : "decode"
                    let label = parameter.label.map { "\($0): " } ?? ""
                    return DecodableBuilder.BuildingData.Item(
                        identifier: enumCase.identifier,
                        function: ".\(enumCase.identifier)(\(label)try container.\(functionName)(\(typeDescription), forKey: key))"
                    )
                }
        )
    }
}
