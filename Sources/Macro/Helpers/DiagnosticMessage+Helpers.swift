//
//  DiagnosticMessage+Helpers.swift
//
//
//  Created by Mikhail Maslo on 21.09.23.
//

import SwiftDiagnostics
import SwiftSyntax

extension DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }
}
