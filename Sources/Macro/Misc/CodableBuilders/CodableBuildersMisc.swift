//
//  DefaultCodableBuilders.swift
//
//
//  Created by Mikhail Maslo on 25.09.23.
//

enum CodableStrategy {
    case singleValue
    case codingKeys
}

struct FunctionBuilder: CodeBuildable {
    typealias Params = [(String?, String)]

    let name: String
    let parameters: Params
    let isOptionalTry: Bool

    init(name: String, parameters: Params, isOptionalTry: Bool = false) {
        self.name = name
        self.parameters = parameters
        self.isOptionalTry = isOptionalTry
    }

    func build() -> String {
        let tryKeyword = isOptionalTry ? "try?" : "try"
        return "\(tryKeyword) \(name)(\(parameters.map { ($0.0.map { "\($0): " } ?? "") + $0.1 }.joined(separator: ",")))"
    }
}

enum KnownAttribute: String {
    case omitCoding
    case codingKey
    case defaultValue
    case valueStrategy
    case customCoding
}
