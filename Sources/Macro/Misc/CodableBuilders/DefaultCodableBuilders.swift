//
//  DefaultCodableBuilders.swift
//
//
//  Created by Mikhail Maslo on 25.09.23.
//

import MacroToolkit
import SwiftSyntax
import SwiftSyntaxBuilder

enum DefaultCodableBuilders {
    enum CodableStrategy {
        case singleValue
        case codingKeys
    }

    struct ThrowingFunc: CodeBuildable {
        typealias Params = [(String?, String)]

        let name: String
        let parameters: Params

        func build() -> String {
            "try \(name)(\(parameters.map { ($0.0.map { "\($0): " } ?? "") + $0.1 }.joined(separator: ",")))"
        }
    }

    enum KnownAttribute: String {
        case omitCoding
        case codingKey
        case defaultValue
        case valueStrategy
        case customCoding
    }
}
