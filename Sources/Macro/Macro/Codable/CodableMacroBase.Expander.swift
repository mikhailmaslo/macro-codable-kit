//
//  CodableMacroBase.Expander.swift
//
//
//  Created by Mikhail Maslo on 26.09.23.
//

import SwiftSyntax

extension CodableMacroBase {
    final class Expander {
        private let codableFactory: CodableBuilderFactory

        init(codableFactory: CodableBuilderFactory) {
            self.codableFactory = codableFactory
        }

        func ensureStructOrClassDecl(declaration: some DeclGroupSyntax) -> Instance? {
            InstanceImpl(declaration: declaration)
        }

        func extensionCodeBuilder(
            instance: Instance,
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
                            instance: instance,
                            conformances: conformances
                        )
                    }
                }
            }
        }

        func membersCodeBuilder(
            instance: Instance,
            conformances: Set<Conformance>
        ) -> CodeBuildable {
            CodeBuilders.content { [self] in
                DefaultCodableBuilders.CodingKeysBuilder(accessModifier: instance.isPublic ? .public : nil, instance: instance)

                if conformances.contains(.Decodable) {
                    codableFactory.makeDecoderBuilder(instance: instance)
                }

                if conformances.contains(.Encodable) {
                    codableFactory.makeEncoderBuilder(instance: instance)
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
