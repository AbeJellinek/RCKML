//
//  AEXML+KMLTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/28/25.
//

import AEXML

extension AEXMLElement {
    func children(named name: String) -> [AEXMLElement] {
        children.filter { $0.name == name }
    }

    struct WrongChildCount: Error {
        var found: Int
    }

    /// Returns the only child with a given tag name. Throws an error if zero or more than one child with the
    /// given name is present.
    func exactlyOneChild(named name: String) throws(WrongChildCount) -> AEXMLElement {
        let childXmls = children(named: name)
        guard let firstChild = childXmls.first else {
            throw WrongChildCount(found: 0)
        }
        guard childXmls.count == 1 else {
            throw WrongChildCount(found: childXmls.count)
        }
        return firstChild
    }
}
