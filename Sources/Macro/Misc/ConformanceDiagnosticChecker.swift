//
//  ConformanceDiagnosticChecker.swift
//
//
//  Created by Mikhail Maslo on 08.10.23.
//

import MacroToolkit
import SwiftSyntax

final class ConformanceDiagnosticChecker {
    struct Config {
        let replacementMacroName: [Conformance: String]

        init(replacementMacroName: [Conformance: String]) {
            self.replacementMacroName = replacementMacroName
        }
    }

    private let config: Config

    init(config: Config) {
        self.config = config
    }

    func verify(
        type: some TypeSyntaxProtocol,
        declaration: some DeclGroupSyntax,
        expectedConformances: Set<Conformance>,
        conformancesToGenerate: Set<Conformance>
    ) throws {
        if expectedConformances == conformancesToGenerate {
            return
        }

        guard !conformancesToGenerate.isEmpty else {
            notifyEmptyConformances(type: type, declaration: declaration, expectedConformances: expectedConformances)

            return
        }

        for conformance in Conformance.allCases
            where expectedConformances.contains(conformance)
            && !conformancesToGenerate.contains(conformance)
        {
            notifyConformanceMismatch(type: type, declaration: declaration, existingConformance: conformance)
        }
    }

    private func notifyConformanceMismatch(
        type: some TypeSyntaxProtocol,
        declaration: some DeclGroupSyntax,
        existingConformance: Conformance
    ) {
        let message: SimpleDiagnosticMessage = .warning(
            message: "'@\(MacroConfiguration.current.name)' macro won't generate '\(existingConformance)' conformance since '\(type.trimmedDescription)' already conformes to it. \(config.replacementMacroName[existingConformance].map { "Consider using '\($0)' instead" } ?? "")",
            diagnosticID: .init(id: #function)
        )
        MacroConfiguration.current.context.diagnose(
            message.diagnose(at: declaration)
        )
    }

    private func notifyEmptyConformances(
        type: some TypeSyntaxProtocol,
        declaration: some DeclGroupSyntax,
        expectedConformances: Set<Conformance>
    ) {
        let message: SimpleDiagnosticMessage = .warning(
            message: "'@\(MacroConfiguration.current.name)' macro has not effect since '\(type.trimmedDescription)' already conformes to \(expectedConformances.map(\.rawValue).sorted()). Consider removing '@\(MacroConfiguration.current.name)'",
            diagnosticID: .init(id: #function)
        )
        MacroConfiguration.current.context.diagnose(
            message.diagnose(at: declaration)
        )
    }
}
