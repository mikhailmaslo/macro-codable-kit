//
//  DeclarationBuilder.swift
//
//
//  Created by Mikhail Maslo on 24.09.23.
//

enum AccessModifier: String {
    case `private`, `public`, `internal`
}

struct DeclarationBuilder: CodeBuildable {
    private let signature: String
    private let content: () -> CodeBuildable

    init(signature: String, @CodeBuilder content: @escaping () -> CodeBuildable) {
        self.signature = signature
        self.content = content
    }

    func build() -> String {
        """
        \(signature) {
            \(content().build())
        }
        """
    }
}

extension String: CodeBuildable {
    func build() -> String {
        self
    }
}

extension [String]: CodeBuildable {
    func build() -> String {
        joined(separator: "\n")
    }
}
