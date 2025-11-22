//
//  KMLEncodable.swift
//  RCKML
//
//  Created by Ryan Linn on 11/18/25.
//

protocol KMLEncodable: KMLObject {
    func encode(to encoder: KMLEncoder) throws
}

enum EncodingValueType {
    case object(any KMLEncodable)
    case value(name: KMLTagName, value: any KMLValue)
}

protocol SomeEncodableKML: SomeKML {
    var encodable: EncodingValueType { get }
}

