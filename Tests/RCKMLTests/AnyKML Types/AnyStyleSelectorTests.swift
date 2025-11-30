//
//  AnyStyleSelectorTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/29/25.
//

import AEXML
@testable import RCKML
import Testing

struct AnyStyleSelectorTests {
    @Test func decodeFromXML() throws {
        let decoder = try KMLDecoder(testXml: """
            <Style id="anyStyleSelector">
            <LineStyle>
            <width>5.0</width>
            </LineStyle>
            </Style>
            """)
        let anySelector = try decoder.decode(AnyKMLStyleSelector.self)
        switch anySelector {
        case .style(let style):
            #expect(style.id == "anyStyleSelector")
            #expect(style.lineStyle?.width == 5.0)
        default:
            Issue.record("Incorrect AnyKMLStyleSelector case")
        }
    }
}
