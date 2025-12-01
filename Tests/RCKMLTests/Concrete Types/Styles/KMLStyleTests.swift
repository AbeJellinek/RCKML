//
//  KMLStyleTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/28/25.
//

@testable import RCKML
import Testing

struct KMLStyleTests {
    @Test func decodeFromXML() throws {
        let decoder1 = try KMLDecoder(testXml: """
            <Style id="style1">
            <LineStyle>
            <width>5.0</width>
            </LineStyle>
            <PolyStyle>
            <fill>1</fill>
            </PolyStyle>
            </Style>
            """)
        let style1 = try decoder1.decode(KMLStyle.self)
        #expect(style1.id == "style1")
        #expect(style1.lineStyle?.width == 5.0)
        #expect(style1.polyStyle?.isFilled == true)

        let decoder2 = try KMLDecoder(testXml: """
            <Style>
            </Style>
            """)
        let style2 = try decoder2.decode(KMLStyle.self)
        #expect(style2.id == nil)
        #expect(style2.lineStyle == nil)
        #expect(style2.polyStyle == nil)
    }

    @Test func encodeToXML() throws {
        let lineStyle = KMLLineStyle(id: "lineStyle")
        let polyStyle = KMLPolyStyle(id: "polyStyle")
        let style = KMLStyle(id: "myStyle", lineStyle: lineStyle, polyStyle: polyStyle)
        let encoder = try KMLEncoder(wrapping: style)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "Style")
        #expect(xmlElement.attributes["id"] == "myStyle")

        let lineStyleElements = xmlElement.children(named: "LineStyle")
        #expect(lineStyleElements.count == 1)
        #expect(lineStyleElements.first?.attributes["id"] == "lineStyle")

        let polyStyleElements = xmlElement.children(named: "PolyStyle")
        #expect(polyStyleElements.count == 1)
        #expect(polyStyleElements.first?.attributes["id"] == "polyStyle")
    }
}
