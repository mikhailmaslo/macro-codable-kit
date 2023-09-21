//
//  CodeBuildable+Helpers.swift
//
//
//  Created by Mikhail Maslo on 24.09.23.
//

import MacroToolkit

enum CodeBuilders {
    static func encoder(accessModifier: AccessModifier? = nil, @CodeBuilder content: @escaping () -> CodeBuildable) -> some CodeBuildable {
        DeclarationBuilder(accessModifier: accessModifier, signature: "func encode(to encoder: Encoder) throws", content: content)
    }

    static func decoder(accessModifier: AccessModifier? = nil, @CodeBuilder content: @escaping () -> CodeBuildable) -> some CodeBuildable {
        DeclarationBuilder(accessModifier: accessModifier, signature: "init(from decoder: Decoder) throws", content: content)
    }

    static func extensionBuilder(
        accessModifier: AccessModifier? = nil,
        name: String,
        conformances: Set<Conformance> = [],
        @CodeBuilder content: @escaping () -> CodeBuildable
    ) -> some CodeBuildable {
        DeclarationBuilder(
            accessModifier: accessModifier,
            signature: "extension \(name)\(!conformances.isEmpty ? ": \(conformances.map(\.rawValue).sorted().joined(separator: ","))" : "")",
            content: content
        )
    }

    static func content(@CodeBuilder content: @escaping () -> CodeBuildable) -> CodeBuildable {
        content()
    }
}

extension DeclarationBuilder {
    init(accessModifier: AccessModifier?, signature: String, @CodeBuilder content: @escaping () -> CodeBuildable) {
        self.init(
            signature: "\(accessModifier.map { "\($0.rawValue) " } ?? "")\(signature)",
            content: content
        )
    }
}

struct SwitchBuilder: CodeBuildable {
    let expression: String
    let content: () -> CodeBuildable

    init(expression: String, @CodeBuilder content: @escaping () -> CodeBuildable) {
        self.expression = expression
        self.content = content
    }

    func build() -> String {
        DeclarationBuilder(signature: "switch \(expression)", content: content).build()
    }
}
