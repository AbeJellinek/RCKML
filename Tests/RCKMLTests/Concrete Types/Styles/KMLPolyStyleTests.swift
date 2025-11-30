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
}
