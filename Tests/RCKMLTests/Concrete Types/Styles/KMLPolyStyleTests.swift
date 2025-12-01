//
//  KMLPolyStyleTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/28/25.
//

@testable import RCKML
import Testing

struct KMLPolyStyleTests {
    @Test func decodeFromXML() throws {
        let decoder1 = try KMLDecoder(testXml: """
            <PolyStyle id="Some Style">
            <fill>1</fill>
            <outline>0</outline>
            <color>ff000000</color>
            </PolyStyle>
            """)
        let style1 = try decoder1.decode(KMLPolyStyle.self)
        #expect(style1.id == "Some Style")
        #expect(style1.isFilled == true)
        #expect(style1.isOutlined == false)
        #expect(style1.color != nil)

        let decoder2 = try KMLDecoder(testXml: """
            <PolyStyle>
            </PolyStyle>
            """)
        let style2 = try decoder2.decode(KMLPolyStyle.self)
        #expect(style2.id == nil)
        #expect(style2.isFilled == false)
        #expect(style2.isOutlined == true)
        #expect(style2.color == nil)
    }

    @Test func encodeToXML() throws {
        let red = KMLColor(red: 1.0, green: 0, blue: 0)
        let style = KMLPolyStyle(id: "myStyle", isFilled: false, isOutlined: true, color: red)
        let encoder = try KMLEncoder(wrapping: style)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "PolyStyle")
        #expect(xmlElement.attributes["id"] == "myStyle")

        let fillElements = xmlElement.children(named: "fill")
        #expect(fillElements.count == 1)
        #expect(fillElements.first?.bool == false)

        let outlineElements = xmlElement.children(named: "outline")
        #expect(outlineElements.count == 1)
        #expect(outlineElements.first?.bool == true)

        let colorElements = xmlElement.children(named: "color")
        #expect(colorElements.count == 1)
        #expect(colorElements.first?.value == "FF0000FF")
    }
}
