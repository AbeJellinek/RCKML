//
//  AnyStyleTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/29/25.
//

import AEXML
@testable import RCKML
import Testing

struct AnyStyleTests {
    @Test func decodeFromXML() throws {
        let decoder = try KMLDecoder(testXml: """
            <Style id="anyStyle">
            <LineStyle>
            <width>5.0</width>
            </LineStyle>
            </Style>
            """)
        let anyStyle = try decoder.decode(AnyKMLStyle.self)
        switch anyStyle {
        case .style(let style):
            #expect(style.id == "anyStyle")
            #expect(style.lineStyle?.width == 5.0)
        default:
            Issue.record("Incorrect AnyKMLStyle case")
        }
    }
}
