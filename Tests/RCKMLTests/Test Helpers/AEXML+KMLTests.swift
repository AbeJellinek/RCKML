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
}
