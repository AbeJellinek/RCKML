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

protocol AnyEncodableKML: AnyKML {
    var encodable: EncodingValueType { get }
}

