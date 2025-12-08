//
//  KMLPointTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/30/25.
//

import AEXML
@testable import RCKML
import Testing

struct KMLPointTests {
    @Test func successfulDecode() throws {
        let decoder1 = try KMLDecoder(testXml: """
            <Point id="Point1">
            <coordinates>1.0,2.0,3.0</coordinates>
            </Point>            
            """)
        let decoded1 = try decoder1.decode(KMLPoint.self)

        #expect(decoded1.id == "Point1")
        #expect(decoded1.coordinate.longitude == 1.0)
        #expect(decoded1.coordinate.latitude == 2.0)
        #expect(decoded1.coordinate.altitude == 3.0)

        let decoder2 = try KMLDecoder(testXml: """
            <Point>
            <coordinates>1.0,2.0</coordinates>
            </Point>
            """)
        let decoded2 = try decoder2.decode(KMLPoint.self)

        #expect(decoded2.id == nil)
        #expect(decoded2.coordinate.longitude == 1.0)
        #expect(decoded2.coordinate.latitude == 2.0)
    }

    @Test func failedDecode() throws {
        let withoutCoordinates = try KMLDecoder(testXml: "<Point></Point>")
        #expect(throws: KMLDecoderError.self) {
            let _ = try withoutCoordinates.decode(KMLPoint.self)
        }
    }

    @Test func encodeWithAltitude() throws {
        let coordinate = KMLCoordinate(latitude: 2.0, longitude: 1.0, altitude: 3.0)
        let point = KMLPoint(id: "Point1", coordinate: coordinate)
        let encoder = try KMLEncoder(wrapping: point)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "Point")
        #expect(xmlElement.attributes["id"] == "Point1")

        let coordinateElement = try xmlElement.exactlyOneChild(named: "coordinates")
        let coordinatesText = coordinateElement.string
        #expect(coordinatesText == "1.0,2.0,3.0")
    }

    @Test func encodeWithoutAltitude() throws {
        let coordinate = KMLCoordinate(latitude: 2.0, longitude: 1.0)
        let point = KMLPoint(coordinate: coordinate)
        let encoder = try KMLEncoder(wrapping: point)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "Point")
        #expect(xmlElement.attributes["id"] == nil)

        let coordinateElement = try xmlElement.exactlyOneChild(named: "coordinates")
        let coordinatesText = coordinateElement.string
        #expect(coordinatesText == "1.0,2.0")
    }
}
