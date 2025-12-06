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
    @Test func initializeAnyStyles() throws {
        let styleUrl = KMLStyleUrl(styleId: "styleUrl")
        let anyStyleUrl = try AnyKMLStyle(styleUrl)
        switch anyStyleUrl {
        case .styleUrl(let wrapped):
            #expect(wrapped == styleUrl)
        default:
            Issue.record()
        }

        let style = KMLStyle(id: "style")
        let anyStyle = try AnyKMLStyle(style)
        switch anyStyle {
        case .style(let wrapped):
            #expect(wrapped.id == "style")
        default:
            Issue.record()
        }
    }

    @Test func decodeStyle() throws {
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
            Issue.record()
        }
    }

    @Test func decodeStyleUrl() throws {
        let decoder = try KMLDecoder(testXml: "<styleUrl>#someStyle</styleUrl>")
        let anyStyle = try decoder.decode(AnyKMLStyle.self)
        switch anyStyle {
        case .styleUrl(let styleUrl):
            #expect(styleUrl.styleId == "someStyle")
        default:
            Issue.record()
        }
    }

    @Test func encodeStyle() throws {
        let style = KMLStyle(id: "style")
        let anyStyle = try AnyKMLStyle(style)
        let encoder = try KMLEncoder(wrapping: anyStyle)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "Style")
        #expect(xmlElement.attributes["id"] == "style")
    }

    @Test func encodeStyleUrl() throws {
        let styleUrl = KMLStyleUrl(styleId: "someStyle")
        let anyStyle = AnyKMLStyle.styleUrl(styleUrl)
        let encoder = try KMLEncoder(wrapping: anyStyle)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "styleUrl")
        #expect(xmlElement.value == "#someStyle")
    }
}
