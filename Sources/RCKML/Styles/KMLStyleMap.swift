//
//  KMLStyleMap.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import AEXML
import Foundation

/// A wrapper around one or two KMLStyles to provide a standard and
/// a highlighted version for a given Feature.
///
/// This implementation only contains the standard (non-highlighted) style
/// option. The map can either contain a KMLStyleUrl or a KMLStyle, but
/// not both.
///
/// For definition, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#stylemap)
public struct KMLStyleMap: KMLStyleSelector {
    public var id: String?
    public var styleUrl: KMLStyleUrl?
    public var style: KMLStyle?
//    var highlighted: KMLStyleUrl //ignore highlighted

    public static var kmlTag: String {
        "StyleMap"
    }

    public init(
        id: String? = nil,
        styleUrl: KMLStyleUrl? = nil,
        style: KMLStyle? = nil
    ) {
        self.id = id
        self.styleUrl = styleUrl
        self.style = style
    }
}

// MARK: - KML Codable

extension KMLStyleMap: KMLCodableObject {
    init(xml: AEXMLElement) throws {
        try Self.verifyXmlTag(xml)
        guard let normalPair = xml.children.first(where: { $0["key"].string == "normal" }) else {
            // TODO: throw?
            return
        }
        id = xml.idAttribute
        style = normalPair.children(of: KMLStyle.self).first
        styleUrl = normalPair.valueIfPresent(of: KMLStyleUrl.self, forKey: .styleUrl)
    }

    var children: [any KMLCodable] {
        if let style {
            style
        } else {
            KMLValueElement(name: .styleUrl, value: styleUrl)
        }
    }
}
