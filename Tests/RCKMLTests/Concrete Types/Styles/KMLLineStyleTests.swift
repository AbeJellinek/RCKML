//
//  KMLLineStyleTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/28/25.
//

@testable import RCKML
import Testing

struct KMLLineStyleTests {
    @Test func decodeFromXML() throws {
        let decoder1 = try KMLDecoder(testXml: """
            <LineStyle id="Some Style">
            <width>5.5</width>
            <color>ff000000</color>
            </LineStyle>
            """)
        let style1 = try decoder1.decode(KMLLineStyle.self)
        #expect(style1.id == "Some Style")
        #expect(style1.width == 5.5)
        #expect(style1.color != nil)

        let decoder2 = try KMLDecoder(testXml: """
            <LineStyle>
            </LineStyle>
            """)
        let style2 = try decoder2.decode(KMLLineStyle.self)
        #expect(style2.id == nil)
        #expect(style2.width == 1.0)
        #expect(style2.color == nil)
    }

    @Test func encodeToXML() throws {
        let red = KMLColor(red: 1.0, green: 0, blue: 0)
        let style1 = KMLLineStyle(id: "myStyle", width: 4.0, color: red)

        Issue.record("Test not implemented")
    }
}
