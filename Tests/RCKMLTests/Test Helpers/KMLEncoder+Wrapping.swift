//
//  KMLEncoder+Wrapping.swift
//  RCKML
//
//  Created by Ryan Linn on 11/30/25.
//

import AEXML
@testable import RCKML

extension KMLEncoder {
    /// Initializes a KMLEncoder wrapping a given `KMLEncodable` object as its root XML element.
    init<K: KMLEncodable>(wrapping object: K) throws {
        let dummyXml = AEXMLElement(name: "Root")
        let temp = KMLEncoder(dummyXml)
        try temp.encodeChild(object)
        let child = temp.xml[K.kmlTag]
        if let error = child.error {
            throw error
        }
        self.init(child)
    }
}

