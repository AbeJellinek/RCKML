//
//  KMLDecoder+TestInitializer.swift
//  RCKML
//
//  Created by Ryan Linn on 11/28/25.
//

import AEXML
@testable import RCKML

extension KMLDecoder {
    init(xml: String) throws {
        let doc = try AEXMLDocument(xml: xml)
        let decoded = doc.root
        if let error = decoded.error {
            throw error
        }
        self.init(decoded)
    }

    
}
