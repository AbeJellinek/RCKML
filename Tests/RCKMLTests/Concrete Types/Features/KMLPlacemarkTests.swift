//
//  KMLPlacemarkTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/30/25.
//

import AEXML
@testable import RCKML
import Testing

struct KMLPlacemarkTests {
    // MARK: Decoding

    @Test func decodeWithoutStyle() throws {
        let decoder = try KMLDecoder(testXml: """
            <Placemark id="aPlacemark">
            <name>My Placemark</name>
            <description>A sample placemark</description>
            <Point><coordinates>0,0</coordinates></Point>
            </Placemark>
            """)

        let placemark = try decoder.decode(KMLPlacemark.self)
        #expect(placemark.id == "aPlacemark")
        #expect(placemark.name == "My Placemark")
        #expect(placemark.featureDescription == "A sample placemark")
        #expect(placemark.geometry?.wrapped is KMLPoint)
        #expect(placemark.style == nil)
    }

    @Test func decodeWithStyleUrl() throws {
        let decoder = try KMLDecoder(testXml: """
            <Placemark>
            <styleUrl>#someUrl</styleUrl>
            </Placemark>
            """)
        let placemark = try decoder.decode(KMLPlacemark.self)
        #expect(placemark.style?.wrapped is KMLStyleUrl)
    }

    @Test func decodeWithStyle() throws {
        let decoder = try KMLDecoder(testXml: """
            <Placemark>
            <Style>
            </Style>
            </Placemark>
            """)
        let placemark = try decoder.decode(KMLPlacemark.self)
        #expect(placemark.style?.wrapped is KMLStyle)
    }

    @Test func decodeFailingWithTwoGeometries() throws {
        let decoder = try KMLDecoder(testXml: """
            <Placemark>
            <Point><coordinates>0,0</coordinates></Point>
            <Point><coordinates>1,1</coordinates></Point>
            </Placemark>
            """)
        #expect(throws: KMLPlacemark.GeometryCountError(count: 2)) {
            _ = try decoder.decode(KMLPlacemark.self)
        }
    }

    // MARK: Encoding

    @Test func encodeWithoutStyle() throws {
        let placemark = KMLPlacemark(
            id: "aPlacemark",
            name: "My Placemark",
            featureDescription: "A sample placemark",
            geometry: nil
        )
        let encoder = try KMLEncoder(wrapping: placemark)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "Placemark")
        #expect(xmlElement.attributes["id"] == "aPlacemark")
        #expect(xmlElement["name"].value == "My Placemark")
        #expect(xmlElement["description"].value == "A sample placemark")
    }

    @Test func encodeWithStyleUrl() throws {
        let placemark = KMLPlacemark(
            name: nil,
            geometry: nil,
            styleUrl: KMLStyleUrl(styleId: "myStyle")
        )
        let encoder = try KMLEncoder(wrapping: placemark)

        let xmlElement = encoder.xml
        let styleUrlElement = try xmlElement.exactlyOneChild(named: "styleUrl")
        #expect(styleUrlElement.value == "#myStyle")
    }

    @Test func encodeWithStyle() throws {
        let style = KMLStyle(id: "myStyle")
        let placemark = KMLPlacemark(
            name: nil,
            geometry: nil,
            style: style
        )
        let encoder = try KMLEncoder(wrapping: placemark)

        let xmlElement = encoder.xml
        let styleElement = try xmlElement.exactlyOneChild(named: "Style")
        #expect(styleElement.attributes["id"] == "myStyle")
    }

    @Test func encodeWithPoint() throws {
        let point = KMLPoint(id: "aPoint", latitude: 0, longitude: 0)
        let placemark = KMLPlacemark(name: nil, geometry: .point(point))
        let encoder = try KMLEncoder(wrapping: placemark)

        let xmlElement = encoder.xml
        let pointElement = try xmlElement.exactlyOneChild(named: "Point")
        #expect(pointElement.attributes["id"] == "aPoint")
    }

    @Test func encodeWithLineString() throws {
        let lineString = KMLLineString(id: "aLine", coordinates: [
            KMLCoordinate(latitude: 0, longitude: 0),
            KMLCoordinate(latitude: 1, longitude: 1)
        ])
        let placemark = KMLPlacemark(name: nil, geometry: .lineString(lineString))
        let encoder = try KMLEncoder(wrapping: placemark)

        let xmlElement = encoder.xml
        let lineStringElement = try xmlElement.exactlyOneChild(named: "LineString")
        #expect(lineStringElement.attributes["id"] == "aLine")
    }

    @Test func encodeWithPolygon() throws {
        // no style, polygon geometry
        let outerBound = try KMLPolygon.LinearRing(coordinates: [
            KMLCoordinate(latitude: 0, longitude: 0),
            KMLCoordinate(latitude: 0, longitude: 1),
            KMLCoordinate(latitude: 1, longitude: 1),
            KMLCoordinate(latitude: 0, longitude: 0)
        ])
        let polygon = KMLPolygon(id: "aPolygon", outerBoundary: outerBound)
        let placemark = KMLPlacemark(name: nil, geometry: .polygon(polygon))
        let encoder = try KMLEncoder(wrapping: placemark)

        let xmlElement = encoder.xml
        let polygonElement = try xmlElement.exactlyOneChild(named: "Polygon")
        #expect(polygonElement.attributes["id"] == "aPolygon")
    }

    @Test func encodeWithMultiGeometry() throws {
        let multiGeo = KMLMultiGeometry(id: "aMulti")
        let placemark = KMLPlacemark(name: nil, geometry: .multiGeometry(multiGeo))
        let encoder = try KMLEncoder(wrapping: placemark)

        let xmlElement = encoder.xml
        let multiGeoElement = try xmlElement.exactlyOneChild(named: "MultiGeometry")
        #expect(multiGeoElement.attributes["id"] == "aMulti")
    }
}
