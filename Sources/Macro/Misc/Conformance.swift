//
//  Conformance.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

import SwiftSyntax

enum Conformance: String, CaseIterable {
    case Codable, Encodable, Decodable

    public static let aliases: [Conformance: Set<Conformance>] = [
        .Codable: [.Decodable, .Encodable],
    ]

    static func makeConformances(_ rawValues: [String]?) -> Set<Conformance> {
        var result = Set<Conformance>()
        for rawValue in rawValues ?? [] {
            guard let conformance = Conformance(rawValue: rawValue) else {
                continue
            }
            if let conformances = Self.aliases[conformance] {
                result.formUnion(conformances)
            }
            result.insert(conformance)
        }
        return result
    }
}
