//
//  KMLEncoder.swift
//  RCKML
//
//  Created by Ryan Linn on 11/21/25.
//

import AEXML

struct KMLEncoder {
    let xml: AEXMLElement

    init<K: KMLEncodable>(for object: K) {
        let baseAttributes = ["id" : object.id].compactMapValues(\.self)
        xml = AEXMLElement(name: K.kmlTag, attributes: baseAttributes)
    }

    init(_ xml: AEXMLElement) {
        self.xml = xml
    }

    func encode<V: KMLValue>(tag: KMLTagName, value: V?) throws {
        // Remove existing value if already set
        xml[tag.name].removeFromParent()

        guard let value else {
            return
        }
        let element = AEXMLElement(name: tag.name, value: value.kmlString)
        xml.addChild(element)
    }

    func addContainer(tag: KMLTagName) throws -> KMLEncoder {
        // Remove existing container if already set
        xml[tag.name].removeFromParent()

        // Add new container element
        let element = AEXMLElement(name: tag.name)
        xml.addChild(element)
        return KMLEncoder(element)
    }

    func encodeChild<C: KMLEncodable>(_ object: C) throws {
        let subEncoder = KMLEncoder(for: object)
        try object.encode(to: subEncoder)
        xml.addChild(subEncoder.xml)
    }

    func encodeChild<C: KMLEncodable>(_ object: C?) throws {
        guard let object else {
            return
        }
        try encodeChild(object)
    }

    func encodeChild<C: SomeEncodableKML>(_ object: C) throws {
        switch object.encodable {
        case .object(let objectType):
            try encodeChild(objectType)
        case .value(let name, let value):
            try encode(tag: name, value: value)
        }
    }

    func encodeChild<C: SomeEncodableKML>(_ object: C?) throws {
        if let object {
            try encodeChild(object)
        }
    }
}
