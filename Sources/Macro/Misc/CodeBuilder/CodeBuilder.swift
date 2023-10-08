//
//  CodeBuilder.swift
//
//
//  Created by Mikhail Maslo on 24.09.23.
//

protocol CodeBuildable {
    func build() -> String
}

@resultBuilder
enum CodeBuilder {
    static func buildBlock(_ components: CodeBuildable...) -> CodeBuildable {
        CompositeCode(components: components)
    }

    // periphery:ignore
    static func buildIf(_ component: CodeBuildable?) -> CodeBuildable {
        component ?? EmptyCodeBuilder()
    }

    static func buildEither(first component: CodeBuildable) -> CodeBuildable {
        component
    }

    static func buildEither(second component: CodeBuildable) -> CodeBuildable {
        component
    }
}

// periphery:ignore
struct EmptyCodeBuilder: CodeBuildable {
    func build() -> String {
        ""
    }
}

struct CompositeCode: CodeBuildable {
    let components: [CodeBuildable]

    func build() -> String {
        components.map { $0.build() }.joined(separator: "\n")
    }
}
