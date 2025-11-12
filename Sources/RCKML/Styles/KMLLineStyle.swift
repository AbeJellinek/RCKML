//
//  KMLLineStyle.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import AEXML
import Foundation

/// A style used to draw lines or polygon boundaries with a given width and color.
///
/// For definition, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#linestyle)
public struct KMLLineStyle: KMLColorStyle {
    public var id: String?
    public var width: Double
    public var color: KMLColor?

    public static var kmlTag: String {
        "LineStyle"
    }

    public init(
        id: String? = nil,
        width: Double = 1.0,
        color: KMLColor? = nil
    ) {
        self.id = id
        self.width = width
        self.color = color
    }
}

// MARK: - KML Codable

extension KMLLineStyle: KMLCodableObject {
    init(xml: AEXML.AEXMLElement) throws {
        try Self.verifyXmlTag(xml)
        id = xml.idAttribute
        width = xml.valueIfPresent(of: Double.self, forKey: .width) ?? 1.0
        color = try xml.value(of: KMLColor.self, forKey: .color)
    }

    var children: [any KMLCodable] {
        KMLValueElement(name: .width, value: width)
        KMLValueElement(name: .color, value: color)
    }
}
