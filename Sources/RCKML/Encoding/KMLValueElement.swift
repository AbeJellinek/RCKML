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

    init(name: KMLTagName, value: KMLValue) {
        self.name = name
        self.value = value
    }

    init?(name: KMLTagName, value: KMLValue?) {
        if let value {
            self.init(name: name, value: value)
        } else {
            return nil
        }
    }
}

extension KMLValueElement: KMLCodable {
    var xmlElement: AEXMLElement {
        AEXMLElement(name: name.name, value: value.kmlString)
    }
}
