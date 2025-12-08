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

        let fillElement = try xmlElement.exactlyOneChild(named: "fill")
        #expect(fillElement.bool == false)

        let outlineElement = try xmlElement.exactlyOneChild(named: "outline")
        #expect(outlineElement.bool == true)

        let colorElement = try xmlElement.exactlyOneChild(named: "color")
        #expect(colorElement.value == "FF0000FF")
    }
}
