//
//  SwiftFormat.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

import SwiftFormat

extension String {
    /// A copy of the string formatted using swift-format.
    var swiftFormatted: Self {
        get throws {
            var formattedString = ""
            // TODO: Should be loaded from a swift-format file that we also use to format our own code.
            var configuration = Configuration()
            configuration.rules["OrderedImports"] = false
            configuration.rules["NoAccessLevelOnExtensionDeclaration"] = false
            configuration.rules["UseLetInEveryBoundCaseVariable"] = false
            configuration.indentation = SwiftFormat.Indent.spaces(4)
            configuration.respectsExistingLineBreaks = false
            configuration.lineBreakBeforeEachArgument = true
            configuration.lineBreakBeforeControlFlowKeywords = false
            configuration.lineBreakBeforeEachGenericRequirement = true
            configuration.lineBreakAroundMultilineExpressionChainComponents = true
            configuration.indentConditionalCompilationBlocks = false
            configuration.maximumBlankLines = 0
            configuration.lineLength = 120
            let formatter = SwiftFormatter(configuration: configuration)
            try formatter.format(
                source: self,
                assumingFileURL: nil,
                to: &formattedString
            ) { diagnostic, sourceLocation in
                print(
                    """
                    ===
                    Formatting the following code produced diagnostic at location \(sourceLocation) (see end):
                    ---
                    \(diagnostic.debugDescription)
                    ===
                    """
                )
                print(diagnostic)
            }
            return formattedString
        }
    }
}
