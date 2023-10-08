//
//  Conformance+Helpers.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

import SwiftSyntax

extension Conformance {
    private static func makeConformances(declaration: some DeclGroupSyntax) -> Set<Conformance> {
        let inheritedTypeDescriptions = declaration.inheritanceClause?.inheritedTypes
            .map { inheritedType in
                inheritedType.type.trimmedDescription
            } ?? []
        return Conformance.makeConformances(inheritedTypeDescriptions)
    }

    private static func makeConformances(protocols: [TypeSyntax]) -> Set<Conformance> {
        var result = Set<Conformance>()
        // Macro can return ['EncodableDecodable'] instead of ['Encodable', 'Decodable']
        if protocols.contains(where: { $0.trimmedDescription.contains(Conformance.Decodable.rawValue) }) {
            result.insert(.Decodable)
        }
        if protocols.contains(where: { $0.trimmedDescription.contains(Conformance.Encodable.rawValue) }) {
            result.insert(.Encodable)
        }
        return result
    }

    /// Macros in testing won't provide protocols property, whereas in real project they will be provided. As a result, it's impossible to test macros behaviour
    /// As a workaround in tests consider all conformances are declared at type
    static func makeConformances(
        protocols: [TypeSyntax],
        declaration: some DeclGroupSyntax,
        type: some TypeSyntaxProtocol,
        expectedConformances: Set<Conformance>
    ) -> Set<Conformance> {
        if type.trimmedDescription.hasSuffix("__testing__") {
            return expectedConformances.subtracting(makeConformances(declaration: declaration))
        } else {
            return makeConformances(protocols: protocols)
        }
    }
}
