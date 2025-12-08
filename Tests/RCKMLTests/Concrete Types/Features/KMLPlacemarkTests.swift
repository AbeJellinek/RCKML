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
        // no style, point geometry
        Issue.record("Not implemented")
    }

    @Test func encodeWithLineString() throws {
        // no style, lineString geometry
        Issue.record("Not implemented")
    }

    @Test func encodeWithPolygon() throws {
        // no style, polygon geometry
        Issue.record("Not implemented")
    }

    @Test func encodeWithMultiGeometry() throws {
        // no style, multigeometry
        Issue.record("Not implemented")
    }
}
