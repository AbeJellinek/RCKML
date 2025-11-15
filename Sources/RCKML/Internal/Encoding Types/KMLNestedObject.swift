//
//  KMLNestedObject.swift
//  RCKML
//
//  Created by Ryan Linn on 11/7/25.
//

import AEXML

struct KMLNestedObject: KMLCodable {
    var tagName: String
    var childObjects: [KMLCodableObject]

    var xmlElement: AEXMLElement {
        let element = AEXMLElement(name: tagName)
        for child in childObjects {
            element.addChild(child.xmlElement)
        }
        return element
    }
}
