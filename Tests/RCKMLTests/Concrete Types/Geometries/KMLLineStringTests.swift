//
//  KMLLineStringTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/30/25.
//

import AEXML
@testable import RCKML
import Testing

struct KMLLineStringTests {
    @Test func successfulDecode() throws {
        let decoder = try KMLDecoder(testXml: """
            <LineString id="LineString1">
            <coordinates>
            1.0,2.0
            3.0,4.0
            </coordinates>
            </LineString>
            """)
        let lineString = try decoder.decode(KMLLineString.self)

        #expect(lineString.id == "LineString1")
        #expect(lineString.coordinates.count == 2)
    }

    @Test func failedDecode() throws {
        let decoder = try KMLDecoder(testXml: "<LineString></LineString>")
        #expect(throws: KMLDecoderError.self) {
            let _ = try decoder.decode(KMLLineString.self)
        }
    }

    @Test func encodeWithIdAndCoordinates() throws {
        let coordinates = [
            KMLCoordinate(latitude: 2.0, longitude: 1.0),
            KMLCoordinate(latitude: 4.0, longitude: 3.0)
        ]
        let lineString = KMLLineString(id: "LineString1", coordinates: coordinates)
        let encoder = try KMLEncoder(wrapping: lineString)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "LineString")
        #expect(xmlElement.attributes["id"] == "LineString1")

        let coordinatesElement = try xmlElement.exactlyOneChild(named: "coordinates")
        let coordinatesText = coordinatesElement.string

        #expect(coordinatesText == "1.0,2.0 3.0,4.0")
    }
}
