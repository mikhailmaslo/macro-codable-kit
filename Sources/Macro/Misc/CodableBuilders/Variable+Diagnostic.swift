//
//  Variable+Diagnostic.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import MacroToolkit

extension Variable {
    func verify(_ allKnownAttributes: AllKnownAttributes) throws {
        try verifyHasTypeAndIdentifier()
        try verifySingleIdentifierAndType()
        try verifyNoDuplicatedAttributes(allKnownAttributes)
        try notStoredPropertiesWithoutKnownAnnotations(allKnownAttributes)
    }

    private func notStoredPropertiesWithoutKnownAnnotations(_ allKnownAttributes: AllKnownAttributes) throws {
        if !isStoredProperty, !allKnownAttributes.isEmpty {
            MacroConfiguration.current.context.diagnose(
                CommonDiagnostic
                    .applicableOnlyToStoredProperties()
                    .diagnose(at: _syntax)
            )

            throw CommonError.diagnosticError
        }
    }

    private func verifyHasTypeAndIdentifier() throws {
        guard let binding = bindings.first else {
            return
        }
        guard binding.identifier != nil, binding.type != nil else {
            MacroConfiguration.current.context.diagnose(
                CommonDiagnostic
                    .missingTypeOfIdentifierError()
                    .diagnose(at: _syntax)
            )

            throw CommonError.diagnosticError
        }
    }

    private func verifySingleIdentifierAndType() throws {
        guard bindings.count == 1 else {
            MacroConfiguration.current.context.diagnose(
                CommonDiagnostic
                    .unsupportedCompoundDeclarationError()
                    .diagnose(at: _syntax)
            )

            throw CommonError.diagnosticError
        }
    }

    private func verifyNoDuplicatedAttributes(_ allKnownAttributes: AllKnownAttributes) throws {
        for (key, attributes) in allKnownAttributes {
            guard attributes.count <= 1 else {
                MacroConfiguration.current.context.diagnose(
                    CommonDiagnostic
                        .redundantAttributeError(
                            annotation: key.rawValue.capitalized,
                            variable: _syntax.trimmedDescription
                        )
                        .diagnose(at: _syntax)
                )

                throw CommonError.diagnosticError
            }
        }
    }
}
