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
    static var domain = ""
    static var name = ""

    static func expansion<Macro: MacroMetaProviding>(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext,
        macro _: Macro.Type
    ) throws -> [ExtensionDeclSyntax] {
        domain = Macro.domain
        name = Macro.name

        let expander = Expander(codableFactory: DefaultCodableBuilderFactoryImpl(strategy: .singleValue))

        guard let instance = expander.ensureStructOrClassDecl(declaration: declaration) else {
            context.diagnose(Diagnostic.requiresStructOrClass.diagnose(at: node))
            return []
        }

        let builder = expander.extensionCodeBuilder(instance: instance, type: type, conformances: Conformance.makeConformances(protocols.map(\.trimmedDescription)))

        var formattedCode = ""
        do {
            formattedCode = try expander.generateAndFormat(codeBuilder: builder)
        } catch {
            print("Couldn't format code = \(builder.build()) with error = \(error)")
            context.diagnose(
                Diagnostic
                    .internalError(message: "Internal Error. Couldn't format code")
                    .diagnose(at: declaration)
            )
            return []
        }

        if formattedCode.isEmpty {
            return []
        }

        guard let extensionDecl = expander.mapToExtensionDeclSyntax(code: formattedCode) else {
            print("Couldn't expand code = \(formattedCode)")
            context.diagnose(
                Diagnostic
                    .internalError(message: "Internal Error. Couldn't create extension")
                    .diagnose(at: declaration)
            )
            return []
        }

        return [extensionDecl]
    }
}
