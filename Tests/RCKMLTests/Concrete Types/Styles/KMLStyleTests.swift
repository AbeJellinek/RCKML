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
}
