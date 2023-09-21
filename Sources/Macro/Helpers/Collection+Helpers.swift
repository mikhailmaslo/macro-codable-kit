//
//  Collection+Helpers.swift
//
//
//  Created by Mikhail Maslo on 23.09.23.
//

extension Collection where Element: Hashable {
    func asSet() -> Set<Element> {
        Set(self)
    }
}

extension Set where Element: Hashable {
    func asArray() -> [Element] {
        Array(self)
    }
}
