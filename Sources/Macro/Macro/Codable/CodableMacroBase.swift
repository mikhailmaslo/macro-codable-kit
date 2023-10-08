//
//  CodableMacroBase.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

import MacroToolkit
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct CodableMacroBase {
    static func expansion(
        of _: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformancesToGenerate: Set<Conformance>,
        expectedConformances: Set<Conformance>,
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let checker = ConformanceDiagnosticChecker(
            config: ConformanceDiagnosticChecker.Config(
                replacementMacroName: [
                    .Decodable: "@\(MacroConfiguration.makeName(macro: EncodableMacro.self))",
                    .Encodable: "@\(MacroConfiguration.makeName(macro: DecodableMacro.self))"
                ]
            )
        )
        try checker.verify(
            type: type,
            declaration: declaration,
            expectedConformances: expectedConformances,
            conformancesToGenerate: conformancesToGenerate
        )

        let expander = InstanceExpander(codableFactory: DefaultCodableBuilderFactoryImpl(strategy: .codingKeys))

        let buildingData: CodableBuildingData
        do {
            buildingData = try expander.verify(declaration: declaration, strategy: .codingKeys, conformances: conformancesToGenerate)
        } catch {
            return []
        }

        let formattedCode: String
        do {
            let codeBuilder = expander.extensionCodeBuilder(type: type, buildingData: buildingData, conformances: conformancesToGenerate)
            formattedCode = try expander.generateAndFormat(codeBuilder: codeBuilder)
        } catch {
            context.diagnose(
                CommonDiagnostic
                    .internalError(message: "Internal Error = \(error). Couldn't format code")
                    .diagnose(at: declaration)
            )
            return []
        }

        if formattedCode.isEmpty {
            return []
        }

        guard let extensionDecl = expander.mapToExtensionDeclSyntax(code: formattedCode) else {
            context.diagnose(
                CommonDiagnostic
                    .internalError(message: "Internal Error. Couldn't create extension from code = \(formattedCode)")
                    .diagnose(at: declaration)
            )
            return []
        }

        return [extensionDecl]
    }
}
