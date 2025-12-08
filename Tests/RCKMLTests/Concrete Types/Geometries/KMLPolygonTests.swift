//
//  KMLPolygonTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/30/25.
//

import AEXML
@testable import RCKML
import Testing

struct KMLPolygonTests {
    enum Rings {
        static let outer = "0.0,0.0 5.0,0.0 5.0,5.0 0.0,5.0 0.0,0.0"
        static let inner1 = "1.0,1.0 2.0,1.0 2.0,2.0 1.0,2.0 1.0,1.0"
        static let inner2 = "3.0,3.0 4.0,3.0 4.0,4.0 3.0,4.0 3.0,3.0"
    }
    enum BadRings {
        static let tooFewCoords = "0.0,0.0 5.0,0.0 0.0,0.0"
        static let unclosed = "0.0,0.0 5.0,0.0 5.0,5.0 0.0,5.0 0.0,1.0"
        static let clockwise = "0.0,0.0 0.0,5.0 5.0,5.0 5.0,0.0 0.0,0.0"
    }

    @Test func decodeLinearRing() throws {
        let decoder = try KMLDecoder(testXml: """
        <LinearRing id="outerRing">
        <coordinates>\(Rings.outer)</coordinates>
        </LinearRing>
        """)
        let ring = try decoder.decode(KMLPolygon.LinearRing.self)

        #expect(ring.id == "outerRing")
        #expect(ring.coordinates.count == 5)
    }

    @Test func failDecodeLinearRing() throws {
        // No coordinates
        let decoderWithNoCoordinates = try KMLDecoder(testXml: """
            <LinearRing></LinearRing>
            """)
        #expect(throws: KMLDecoderError.self) {
            _ = try decoderWithNoCoordinates.decode(KMLPolygon.LinearRing.self)
        }

        // must have four or more coordinates
        let decoderWithTooFewCoordinates = try KMLDecoder(testXml: """
            <LinearRing>
            <coordinates>\(BadRings.tooFewCoords)</coordinates>
            </LinearRing>
            """)
        #expect(throws: KMLPolygon.LinearRing.RequirementViolation.tooFewCoordinates) {
            _ = try decoderWithTooFewCoordinates.decode(KMLPolygon.LinearRing.self)
        }

        // first and last coordinate must be equal
        let decoderWithOpenRing = try KMLDecoder(testXml: """
            <LinearRing>
            <coordinates>\(BadRings.unclosed)</coordinates>
            </LinearRing>
            """)
        #expect(throws: KMLPolygon.LinearRing.RequirementViolation.unclosedRing) {
            _ = try decoderWithOpenRing.decode(KMLPolygon.LinearRing.self)
        }

        // TODO: expect counterclockwise coordinates
        /*
        // must be laid out counterclockwise
        let decoderWithClockwiseCoordinates = try KMLDecoder(testXml: """
            <LinearRing>
            <coordinates>\(BadRings.clockwise)</coordinates>
            </LinearRing>
            """)
        #expect(throws: KMLPolygon.LinearRing.RequirementViolation.clockwiseCoordinates) {
            _ = try decoderWithClockwiseCoordinates.decode(KMLPolygon.LinearRing.self)
        }
         */
    }

    @Test func encodeLinearRing() throws {
        // outerring coordinates: "0,0 5,0 5,5 0,5 0,0"
        let coordinates = [
            KMLCoordinate(latitude: 0, longitude: 0),
            KMLCoordinate(latitude: 0, longitude: 5),
            KMLCoordinate(latitude: 5, longitude: 5),
            KMLCoordinate(latitude: 5, longitude: 0),
            KMLCoordinate(latitude: 0, longitude: 0)
        ]
        let linearRing = try KMLPolygon.LinearRing(id: "ring", coordinates: coordinates)
        let encoder = try KMLEncoder(wrapping: linearRing)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "LinearRing")
        #expect(xmlElement.attributes["id"] == "ring")

        let coordinatesElement = try xmlElement.exactlyOneChild(named: "coordinates")
        let coordinatesText = coordinatesElement.string

        #expect(coordinatesText == Rings.outer)
    }

    @Test func decodeBasicPolygon() throws {
        let decoder = try KMLDecoder(testXml: """
            <Polygon id="JustPolygon">
            <outerBoundaryIs>
            <LinearRing>
            <coordinates>\(Rings.outer)</coordinates>
            </LinearRing>
            </outerBoundaryIs>
            </Polygon>
            """)
        let polygon = try decoder.decode(KMLPolygon.self)

        #expect(polygon.id == "JustPolygon")
        #expect(polygon.outerBoundaryIs.coordinates.count == 5)
        #expect(polygon.innerBoundaryIs == nil)
    }

    @Test func decodePolygonWithInnerBoundary() throws {
        let decoder = try KMLDecoder(testXml: """
            <Polygon id="HolePolygon">
            <outerBoundaryIs>
            <LinearRing>
            <coordinates>\(Rings.outer)</coordinates>
            </LinearRing>
            </outerBoundaryIs>
            <innerBoundaryIs>
            <LinearRing>
            <coordinates>\(Rings.inner1)</coordinates>
            </LinearRing>
            </innerBoundaryIs>
            </Polygon>
            """)
        let polygon = try decoder.decode(KMLPolygon.self)

        let innerBoundaries = try #require(polygon.innerBoundaryIs)
        #expect(innerBoundaries.count == 1)
        let innerBoundary = try #require(innerBoundaries.first)
        #expect(innerBoundary.coordinates.count == 5)
    }

    @Test func decodePolygonWithMultipleInnerBoundaries() throws {
        let decoder = try KMLDecoder(testXml: """
            <Polygon id="HoleyPolygon">
            <outerBoundaryIs>
            <LinearRing>
            <coordinates>\(Rings.outer)</coordinates>
            </LinearRing>
            </outerBoundaryIs>
            <innerBoundaryIs>
            <LinearRing>
            <coordinates>\(Rings.inner1)</coordinates>
            </LinearRing>
            </innerBoundaryIs>
            <innerBoundaryIs>
            <LinearRing>
            <coordinates>\(Rings.inner2)</coordinates>
            </LinearRing>
            </innerBoundaryIs>
            </Polygon>
            """)
        let polygon = try decoder.decode(KMLPolygon.self)

        let innerBoundaries = try #require(polygon.innerBoundaryIs)
        #expect(innerBoundaries.count == 2)
        let innerBoundary1 = try #require(innerBoundaries.first)
        #expect(innerBoundary1.coordinates.count == 5)
        let innerBoundary2 = try #require(innerBoundaries.last)
        #expect(innerBoundary2.coordinates.count == 5)
    }

    @Test func failedDecodes() throws {
        // no outer boundary
        let noOuterDecoder = try KMLDecoder(testXml: """
        <Polygon>
        <innerBoundaryIs>
        <LinearRing>
        <coordinates>\(Rings.outer)</coordinates>
        </LinearRing>
        </innerBoundaryIs>
        </Polygon>
        """)
        #expect(throws: KMLDecoderError.self) {
            _ = try noOuterDecoder.decode(KMLPolygon.self)
        }

        // corrupt outer boundary
        let badOuterDecoder = try KMLDecoder(testXml: """
            <Polygon>
            <outerBoundaryIs>
            <LinearRing>
            <coordinates>0,0</coordinates>
            </LinearRing>
            </outerBoundaryIs>
            </Polygon>
            """)
        #expect(throws: KMLPolygon.LinearRing.RequirementViolation.tooFewCoordinates) {
            _ = try badOuterDecoder.decode(KMLPolygon.self)
        }

        // corrupt inner boundary
        let badInnerDecoder = try KMLDecoder(testXml: """
            <Polygon>
            <outerBoundaryIs>
            <LinearRing>
            <coordinates>\(Rings.outer)</coordinates>
            </LinearRing>
            </outerBoundaryIs>
            <innerBoundaryIs>
            <LinearRing>
            <coordinates>0,0</coordinates>
            </LinearRing>
            </innerBoundaryIs>
            </Polygon>
            """)
        #expect(throws: KMLPolygon.LinearRing.RequirementViolation.tooFewCoordinates) {
            _ = try badInnerDecoder.decode(KMLPolygon.self)
        }
    }

    @Test func encodePolygon() throws {
        let outerCoordinates = [
            KMLCoordinate(latitude: 0, longitude: 0),
            KMLCoordinate(latitude: 0, longitude: 5),
            KMLCoordinate(latitude: 5, longitude: 5),
            KMLCoordinate(latitude: 5, longitude: 0),
            KMLCoordinate(latitude: 0, longitude: 0)
        ]
        let outerBound = try KMLPolygon.LinearRing(coordinates: outerCoordinates)

        let inner1Coordinates = [
            KMLCoordinate(latitude: 1, longitude: 1),
            KMLCoordinate(latitude: 1, longitude: 2),
            KMLCoordinate(latitude: 2, longitude: 2),
            KMLCoordinate(latitude: 2, longitude: 1),
            KMLCoordinate(latitude: 1, longitude: 1)
        ]
        let innerBound1 = try KMLPolygon.LinearRing(id: "inner1", coordinates: inner1Coordinates)

        let inner2Coordinates = [
            KMLCoordinate(latitude: 3, longitude: 3),
            KMLCoordinate(latitude: 3, longitude: 4),
            KMLCoordinate(latitude: 4, longitude: 4),
            KMLCoordinate(latitude: 4, longitude: 3),
            KMLCoordinate(latitude: 3, longitude: 3)
        ]
        let innerBound2 = try KMLPolygon.LinearRing(id: "inner2", coordinates: inner2Coordinates)

        let polygon = KMLPolygon(
            id: "wholePoly",
            outerBoundary: outerBound,
            innerBoundaries: [innerBound1, innerBound2]
        )
        let encoder = try KMLEncoder(wrapping: polygon)
        let polygonXml = encoder.xml

        // Polygon
        #expect(polygonXml.name == "Polygon")
        #expect(polygonXml.attributes["id"] == "wholePoly")

        // outerBoundaryIs
        let outerBoundary = try polygonXml.exactlyOneChild(named: "outerBoundaryIs")
        // -- LinearRing
        let outerLineRing = try outerBoundary.exactlyOneChild(named: "LinearRing")
        // ---- coordinates
        let coordinatesElement = try outerLineRing.exactlyOneChild(named: "coordinates")
        // ------ coordinates text value
        #expect(coordinatesElement.string == Rings.outer)

        // innerBoundaries
        let innerBoundaries = polygonXml.children(named: "innerBoundaryIs")
        #expect(innerBoundaries.count == 2)

        // InnerBoundaryIs1
        let inner1Xml = try #require(innerBoundaries.first { $0["LinearRing"].attributes["id"] == "inner1" })
        #expect(inner1Xml["LinearRing"]["coordinates"].value == Rings.inner1)

        // InnerBoundaryIs2
        let inner2Xml = try #require(innerBoundaries.first { $0["LinearRing"].attributes["id"] == "inner2" })
        #expect(inner2Xml["LinearRing"]["coordinates"].value == Rings.inner2)
    }
}
