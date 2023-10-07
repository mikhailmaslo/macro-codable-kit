//
//  DefaultCodableBuilders.CodingKeysBuilder.swift
//
//
//  Created by Mikhail Maslo on 07.10.23.
//

import MacroToolkit

extension DefaultCodableBuilders {
    struct CodingKeysBuilder: CodeBuildable {
        private let accessModifier: AccessModifier?
        private let keyValues: [(String, String?)]

        init(accessModifier: AccessModifier?, keyValues: [(String, String?)]) {
            self.accessModifier = accessModifier
            self.keyValues = keyValues
        }

        func build() -> String {
            if keyValues.isEmpty {
                return ""
            } else {
                return DeclarationBuilder(accessModifier: accessModifier, signature: "enum CodingKeys: String, CodingKey") {
                    keyValues.map { "case \($0.0)" + ($0.1.map { " = \"\($0)\"" } ?? "") }
                }.build()
            }
        }
    }
}

// MARK: - Enum

extension DefaultCodableBuilders.CodingKeysBuilder {
    init(accessModifier: AccessModifier?, enumDecl: Enum) {
        self.accessModifier = accessModifier
        keyValues = enumDecl.cases.map { ($0.identifier, nil) }
    }
}

// MARK: - Instance

extension DefaultCodableBuilders.CodingKeysBuilder {
    init(accessModifier: AccessModifier?, instance: Instance) {
        self.init(
            accessModifier: accessModifier,
            keyValues: instance.members
                .flatMap { member -> [(String, String?)] in
                    guard let variable = member.asVariable, !variable.isStatic else {
                        return []
                    }

                    let knownAttributes = variable.knownAttributes()
                    guard knownAttributes[.omitCoding] == nil else {
                        return []
                    }

                    return variable.bindings.compactMap { binding -> (String, String?)? in
                        guard let identifier = binding.identifier else { return nil }

                        return (identifier, (knownAttributes[.codingKey]?.first as? CodingKey)?.key)
                    }
                }
        )
    }
}
