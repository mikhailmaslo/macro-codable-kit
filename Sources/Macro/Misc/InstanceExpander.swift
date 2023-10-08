//
//  InstanceExpander.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import SwiftSyntax

final class InstanceExpander {
    private let codableFactory: CodableBuilderFactory

    init(codableFactory: CodableBuilderFactory) {
        self.codableFactory = codableFactory
    }

    func verify(
        declaration: some DeclGroupSyntax,
        strategy: CodableStrategy,
        conformances: Set<Conformance>
    ) throws -> CodableBuildingData {
        guard let instance = InstanceImpl(declaration: declaration), instance.isStruct else {
            MacroConfiguration.current.context.diagnose(
                CommonDiagnostic
                    .requiresStruct()
                    .diagnose(at: declaration)
            )
            throw CommonError.diagnosticError
        }

        let accessModifier: AccessModifier? = instance.isPublic ? .public : nil

        let codingKeysBuildingData: CodingKeysBuilder.BuildingData?
        if strategy == .codingKeys {
            codingKeysBuildingData = try CodingKeysBuilder.verify(
                accessModifier: accessModifier,
                instance: instance
            )
        } else {
            codingKeysBuildingData = nil
        }

        let encodingBuildingData: EncodableBuilder.BuildingData?
        if conformances.contains(.Encodable) {
            encodingBuildingData = try EncodableBuilder.verify(
                accessModifier: accessModifier,
                strategy: strategy,
                instance: instance
            )
        } else {
            encodingBuildingData = nil
        }

        let decodingBuildingData: DecodableBuilder.BuildingData?
        if conformances.contains(.Decodable) {
            decodingBuildingData = try DecodableBuilder.verify(
                accessModifier: accessModifier,
                strategy: strategy,
                instance: instance
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
            if let codingKeysBuildingData = buildingData.codingKeysBuildingData {
                codableFactory.makeCodingKeysBuilder(buildingData: codingKeysBuildingData)
            }

            if let decodingBuildingData = buildingData.decodingBuildingData {
                codableFactory.makeDecoderBuilder(buildingData: decodingBuildingData)
            }

            if let encodingBuildingData = buildingData.encodingBuildingData {
                codableFactory.makeEncoderBuilder(buildingData: encodingBuildingData)
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
