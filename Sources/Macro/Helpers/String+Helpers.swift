//
//  String+Helpers.swift
//
//
//  Created by Mikhail Maslo on 03.10.23.
//

extension String {
    func lowercasingFirstLetter() -> String {
        guard !isEmpty else { return self }
        let firstLetterLowercased = prefix(1).lowercased()
        let remainingString = dropFirst()
        return firstLetterLowercased + remainingString
    }
}
