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
        let decoder = try KMLDecoder(testXml: Samples.Styles.styleMapWithUrlsXml)
        let styleMap = try decoder.decode(KMLStyleMap.self)
        #expect(styleMap.id == "urlExample")

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
        let decoder = try KMLDecoder(testXml: Samples.Styles.styleMapWithStylesXml)
        let styleMap = try decoder.decode(KMLStyleMap.self)
        #expect(styleMap.id == "styleExample")

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

    @Test func encodeWithStyleUrls() throws {
        let url1 = KMLStyleUrl(styleId: "url1")
        let url2 = KMLStyleUrl(styleId: "url2")
        let map = KMLStyleMap(id: "styleMap", normal: url1, highlight: url2)
        let encoder = try KMLEncoder(wrapping: map)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "StyleMap")
        #expect(xmlElement.attributes["id"] == "styleMap")

        let pairs = xmlElement.children(named: "Pair")
        #expect(pairs.count == 2)
        let normalPair = try #require(pairs.first(where: { $0["key"].value == "normal" }))
        #expect(normalPair["styleUrl"].value == "#url1")

        let highlightPair = try #require(pairs.first(where: { $0["key"].value == "highlight" }))
        #expect(highlightPair["styleUrl"].value == "#url2")
    }

    @Test func encodeWithStyles() throws {
        let style1 = KMLStyle(id: "style1")
        let style2 = KMLStyle(id: "style2")
        let map = KMLStyleMap(id: "styleMap", normal: style1, highlight: style2)
        let encoder = try KMLEncoder(wrapping: map)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "StyleMap")
        #expect(xmlElement.attributes["id"] == "styleMap")

        let pairs = xmlElement.children(named: "Pair")
        #expect(pairs.count == 2)
        let normalPair = try #require(pairs.first(where: { $0["key"].value == "normal" }))
        let normalStyle = try normalPair.exactlyOneChild(named: "Style")
        #expect(normalStyle.attributes["id"] == "style1")

        let highlightPair = try #require(pairs.first(where: { $0["key"].value == "highlight" }))
        let highlightStyle = try highlightPair.exactlyOneChild(named: "Style")
        #expect(highlightStyle.attributes["id"] == "style2")
    }
}
