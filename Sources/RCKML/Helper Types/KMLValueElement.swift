//
//  KMLValueElement.swift
//  RCKML
//
//  Created by Ryan Linn on 11/6/25.
//

import AEXML
import Foundation

struct KMLValueElement {
    var name: KMLTagName
    var value: KMLValue
}

extension KMLValueElement: KMLEncodable {
    var xmlElement: AEXMLElement {
        AEXMLElement(name: name.name, value: value.kmlString)
    }
}
