//
//  KMLPolyStyle.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import AEXML
import Foundation

/// A style used to determine fill color and whether to draw the outline of a polygon.
///
/// For definition, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#polystyle)
public struct KMLPolyStyle: KMLColorStyle {
    public var id: String?
    public var isFilled: Bool
    public var isOutlined: Bool
    public var color: KMLColor?

    public static var kmlTag: String {
        "PolyStyle"
    }

    public init(
        id: String?,
        isFilled: Bool = false,
        isOutlined: Bool = true,
        color: KMLColor? = nil
    ) {
        self.id = id
        self.isFilled = isFilled
        self.isOutlined = isOutlined
        self.color = color
    }
}

// MARK: - KML Codable

private extension KMLTagName {
    static let isFilled = KMLTagName("fill")
    static let isOutlined = KMLTagName("outline")
}

extension KMLPolyStyle: KMLCodableObject {
    init(xml: AEXMLElement) throws {
        try Self.verifyXmlTag(xml)
        id = xml.idAttribute
        color = try xml.value(of: KMLColor.self, forKey: .color)
        isFilled = xml.valueIfPresent(of: Bool.self, forKey: .isFilled) ?? false
        isOutlined = xml.valueIfPresent(of: Bool.self, forKey: .isOutlined) ?? true
    }

    var children: [any KMLCodable] {
        KMLValueElement(name: .color, value: color)
        KMLValueElement(name: .isFilled, value: isFilled)
        KMLValueElement(name: .isOutlined, value: isOutlined)
    }
}
