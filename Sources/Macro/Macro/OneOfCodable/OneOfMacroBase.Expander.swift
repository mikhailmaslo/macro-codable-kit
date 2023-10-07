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
        func ensureEnumDecl(declaration: some DeclGroupSyntax) -> Enum? {
            Enum(declaration)
        }

        func extensionCodeBuilder(
            enumDecl: Enum,
            type: some TypeSyntaxProtocol,
            conformances: Set<Conformance>
        ) -> CodeBuildable {
            CodeBuilders.content {
                if !conformances.isEmpty {
                    CodeBuilders.extensionBuilder(
                        accessModifier: nil,
                        name: type.trimmedDescription,
                        conformances: conformances
                    ) { [self] in
                        membersCodeBuilder(
                            enumDecl: enumDecl,
                            conformances: conformances
                        )
                    }
                }
            }
        }

        func membersCodeBuilder(
            enumDecl: Enum,
            conformances: Set<Conformance>
        ) -> CodeBuildable {
            CodeBuilders.content { [self] in
                DefaultCodableBuilders.CodingKeysBuilder(accessModifier: enumDecl.isPublic ? .public : nil, enumDecl: enumDecl)

                if conformances.contains(.Decodable) {
                    decoder(enumDecl: enumDecl)
                }

                if conformances.contains(.Encodable) {
                    encoder(enumDecl: enumDecl)
                }
            }
        }

        private func decoder(enumDecl: Enum) -> some CodeBuildable {
            CodeBuilders.decoder(accessModifier: enumDecl.isPublic ? .public : nil) {
                "let container = try decoder.container(keyedBy: CodingKeys.self)"

                """
                guard let key = container.allKeys.first else {
                    throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case."))
                }
                """

                SwitchBuilder(expression: "key") {
                    enumDecl.cases
                        .compactMap { enumCase -> String? in
                            guard
                                let caseValue = enumCase.value
                            else {
                                return nil
                            }

                            let parameter: EnumCaseAssociatedValueParameter
                            switch caseValue {
                            case let .associatedValue(parameters):
                                if let firstParameter = parameters.first {
                                    parameter = firstParameter
                                } else {
                                    return nil
                                }
                            case .rawValue:
                                return nil
                            }

                            let typeDescription = parameter.type._baseSyntax.trimmedDescription
                            return """
                            case .\(enumCase.identifier):
                                self = .\(enumCase.identifier)(try container.decode(\(typeDescription).self, forKey: key))
                            """
                        }
                }
            }
        }

        private func encoder(enumDecl: Enum) -> some CodeBuildable {
            CodeBuilders.encoder(accessModifier: enumDecl.isPublic ? .public : nil) {
                "var container = encoder.container(keyedBy: CodingKeys.self)"

                SwitchBuilder(expression: "self") {
                    enumDecl.cases
                        .map { enumCase in
                            """
                                case .\(enumCase.identifier)(let payload):
                                    try container.encode(payload, forKey: .\(enumCase.identifier))
                            """
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
