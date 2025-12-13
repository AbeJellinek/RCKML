//
//  KMLDocumentTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/30/25.
//

import AEXML
@testable import RCKML
import Testing

struct KMLDocumentTests {
    @Test func decodeFullDocument() throws {
        let decoder = try KMLDecoder(testXml: Samples.Document.sampleXml)
        let document = try decoder.decode(KMLDocument.self)
        #expect(document.id == "sampleDocument")
        #expect(document.name == "Sample Document")
        #expect(document.featureDescription == "A sample document")

        // Two StyleMaps
        #expect(document.styles.count == 2)
        #expect(document.styles["urlExample"] != nil)
        #expect(document.styles["styleExample"] != nil)

        #expect(document.features.count == 4)

        // One folder
        let _ = try #require(
            document
                .features
                .map(\.wrapped)
                .compactMap { $0 as? KMLFolder }
                .first
        )

        // Three placemarks
        let placemarks = document.features.compactMap { $0.wrapped as? KMLPlacemark }
        #expect(placemarks.count == 3)
        #expect(placemarks.filter({ $0.geometry?.wrapped is KMLPoint }).count == 1)
        #expect(placemarks.filter({ $0.geometry?.wrapped is KMLLineString }).count == 1)
        #expect(placemarks.filter({ $0.geometry?.wrapped is KMLPolygon }).count == 1)
    }

    @Test func encodeFullDocument() throws {
        let document = KMLDocument(
            id: "sampleDocument",
            name: "Sample Document",
            featureDescription: "A sample document",
            features: [
                .placemark(.sampleWithPoint()),
                .placemark(.sampleWithPolygon()),
                .placemark(.sampleWithLineString())
            ],
            styles: [
                .style(.sampleRedLine()),
                .style(.sampleBlueFilledPolygon())
            ]
        )

        let encoder = try KMLEncoder(wrapping: document)

        let xmlElement = encoder.xml
        let placemarkContents = xmlElement.children(named: "Placemark")
        #expect(placemarkContents.count == 3)
        let styles = xmlElement.children(named: "Style")
        #expect(styles.count == 2)
    }
}
