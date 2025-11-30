//
//  KMLDecoder+TestInitializer.swift
//  RCKML
//
//  Created by Ryan Linn on 11/28/25.
//

import AEXML
@testable import RCKML

extension KMLDecoder {
    /// Embeds the given XML string in a `Root` element, so the provided XML can be accessed by
    /// `decode` functions
    init(testXml: String) throws {
        let rootedString = "<Root>" + testXml + "</Root>"
        let doc = try AEXMLDocument(xml: rootedString)
        let decoded = doc.root
        if let error = decoded.error {
            throw error
        }
        self.init(decoded)
    }
}
