//
//  KMLDecodable.swift
//  RCKML
//
//  Created by Ryan Linn on 11/18/25.
//

protocol KMLDecodable: KMLObject {
    init(from decoder: KMLDecoder) throws
}

protocol AnyDecodableKML: AnyKML {
    init(from decoder: KMLDecoder) throws
}
