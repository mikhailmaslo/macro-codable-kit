//
//  AllOfMacro.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

import MacroToolkit
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct AllOfMacroBase {
    static func expansion(
        of _: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let expander = InstanceExpander(codableFactory: DefaultCodableBuilderFactoryImpl(strategy: .singleValue))
        let conformances = Conformance.makeConformances(protocols.map(\.trimmedDescription))

        let buildingData: CodableBuildingData
        do {
            buildingData = try expander.verify(declaration: declaration, strategy: .singleValue, conformances: conformances)
        } catch {
            return []
        }

        let formattedCode: String
        do {
            let codeBuilder = expander.extensionCodeBuilder(type: type, buildingData: buildingData, conformances: conformances)
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
