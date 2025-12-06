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
    @Test func initializeAnyStyleSelectors() throws {
        let style = KMLStyle(id: "style")
        let anyStyle = try AnyKMLStyleSelector(style)
        switch anyStyle {
        case .style(let wrapped):
            #expect(wrapped.id == "style")
        default:
            Issue.record()
        }

        let styleMap = KMLStyleMap(
            id: "styleMap",
            normal: KMLStyleUrl(styleId: "normalUrl")
        )
        let anyStyleMap = AnyKMLStyleSelector.styleMap(styleMap)
        switch anyStyleMap {
        case .styleMap(let wrapped):
            #expect(wrapped.id == "styleMap")
            #expect(wrapped.highlightStyle == nil)
            if case .styleUrl(let wrappedUrl) = wrapped.normalStyle {
                #expect(wrappedUrl.styleId == "normalUrl")
            } else {
                Issue.record()
            }
        default:
            Issue.record()
        }
    }

    @Test func decodeStyle() throws {
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

    @Test func decodeStyleMap() throws {
        let decoder = try KMLDecoder(testXml: """
            <StyleMap id="aStyleMap">
            <Pair>
            <key>normal</key>
            <styleUrl>#normalUrl</styleUrl>
            </Pair>
            </StyleMap>
            """)
        let anySelector = try decoder.decode(AnyKMLStyleSelector.self)
        switch anySelector {
        case .styleMap(let wrapped):
            #expect(wrapped.id == "aStyleMap")
            #expect(wrapped.highlightStyle == nil)
            if case .styleUrl(let wrappedUrl) = wrapped.normalStyle {
                #expect(wrappedUrl.styleId == "normalUrl")
            } else {
                Issue.record()
            }
        default:
            Issue.record()
        }
    }

    @Test func encodeStyle() throws {
        let style = KMLStyle(id: "style")
        let anySelector = try AnyKMLStyleSelector(style)
        let encoder = try KMLEncoder(wrapping: anySelector)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "Style")
        #expect(xmlElement.attributes["id"] == "style")
    }

    @Test func encodeStyleMap() throws {
        let normalUrl = KMLStyleUrl(styleId: "normalUrl")
        let styleMap = KMLStyleMap(id: "styleMap", normal: normalUrl)
        let anySelector = try AnyKMLStyleSelector(styleMap)
        let encoder = try KMLEncoder(wrapping: anySelector)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "StyleMap")
        #expect(xmlElement.attributes["id"] == "styleMap")
    }
}
