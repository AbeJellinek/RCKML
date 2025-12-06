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

    /// Initializes a KMLEncoder wrapping a given `AnyEncodableKML` instance as its root XML element.
    init<K: AnyEncodableKML>(wrapping object: K) throws {
        let dummyXml = AEXMLElement(name: "Root")
        let temp = KMLEncoder(dummyXml)
        try temp.encodeChild(object)
        let child: AEXMLElement
        switch object.encodable {
        case .object(let encodableObject):
            child = temp.xml[type(of: encodableObject).kmlTag]
        case .value(let name, let value):
            child = temp.xml[name.name]
        }
        if let error = child.error {
            throw error
        }
        self.init(child)
    }
}

