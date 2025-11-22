//
//  KMLDecodable.swift
//  RCKML
//
//  Created by Ryan Linn on 11/18/25.
//

protocol KMLDecodable: KMLObject {
    init(from decoder: KMLDecoder) throws
}

protocol SomeDecodableKML: SomeKML {
    init(from decoder: KMLDecoder) throws
}
