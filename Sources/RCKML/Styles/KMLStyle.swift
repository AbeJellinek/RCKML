//
//  KMLStyle.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import AEXML
import Foundation

/// A wrapper around possible KML style types used to determine
/// drawing behavior for an object, referenced either inside a
/// KMLFeature, or from a KMLStyleMap by its id.
///
/// A KMLStyle can contain up to one of each type of KMLColorStyle,
/// plus ListStyle.
///
/// For definition, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#style)
public struct KMLStyle: KMLStyleSelector {
    public var id: String?
    public var lineStyle: KMLLineStyle?
    public var polyStyle: KMLPolyStyle?

    public var isEmpty: Bool {
        lineStyle?.color == nil && polyStyle?.color == nil
    }

    public static var kmlTag: String {
        "Style"
    }

    public init(
        id: String? = nil,
        lineStyle: KMLLineStyle? = nil,
        polyStyle: KMLPolyStyle? = nil
    ) {
        self.id = id
        self.lineStyle = lineStyle
        self.polyStyle = polyStyle
    }
}

// MARK: - KML Codable

extension KMLStyle: KMLCodableObject {
    init(xml: AEXMLElement) throws {
        try Self.verifyXmlTag(xml)
        id = xml.idAttribute

        lineStyle = xml.children(of: KMLLineStyle.self).first
        polyStyle = xml.children(of: KMLPolyStyle.self).first
    }

    var children: [any KMLCodable] {
        lineStyle
        polyStyle
    }
}
