//
//  KMLStyleMapTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/28/25.
//

import AEXML
@testable import RCKML
import Testing

struct KMLStyleMapTests {
    @Test func decodeWithStyleUrls() throws {
        let decoder = try KMLDecoder(testXml: """
            <StyleMap id="URLs Example">
            <Pair>
            <key>normal</key>
            <styleUrl>#normalStyle</styleUrl>
            </Pair>
            <Pair>
            <key>highlight</key>
            <styleUrl>#highlightStyle</styleUrl>
            </Pair>
            </StyleMap>
            """)
        let styleMap = try decoder.decode(KMLStyleMap.self)
        #expect(styleMap.id == "URLs Example")

        switch styleMap.normalStyle {
        case .styleUrl(let url):
            #expect(url.styleId == "normalStyle")
        default:
            Issue.record("Incorrect normal style pair type - \(styleMap.normalStyle)")
        }

        switch styleMap.highlightStyle {
        case .styleUrl(let url):
            #expect(url.styleId == "highlightStyle")
        default:
            Issue.record("Incorrect highlight style pair type - \(styleMap.highlightStyle)")
        }
    }

    @Test func decodeWithStyles() throws {
        let decoder = try KMLDecoder(testXml: """
            <StyleMap id="Styles Example">
            <Pair>
            <key>normal</key>
            <Style id="normalStyle"></Style>
            </Pair>
            <Pair>
            <key>highlight</key>
            <Style id="highlightStyle"></Style>
            </Pair>
            </StyleMap>
            """)
        let styleMap = try decoder.decode(KMLStyleMap.self)
        #expect(styleMap.id == "Styles Example")

        switch styleMap.normalStyle {
        case .style(let style):
            #expect(style.id == "normalStyle")
        default:
            Issue.record("Incorrect normal style pair type - \(styleMap.normalStyle)")
        }

        switch styleMap.highlightStyle {
        case .style(let style):
            #expect(style.id == "highlightStyle")
        default:
            Issue.record("Incorrect highlight style type - \(styleMap.highlightStyle)")
        }
    }

    @Test func decodeWithoutHighlight() throws {
        let decoder = try KMLDecoder(testXml: """
            <StyleMap id="Only Normal">
            <Pair>
            <key>normal</key>
            <styleUrl>#normalStyle</styleUrl>
            </Pair>
            </StyleMap>
            """)
        let styleMap = try decoder.decode(KMLStyleMap.self)
        #expect(styleMap.id == "Only Normal")
        #expect(styleMap.highlightStyle == nil)
    }
}
