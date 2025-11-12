//
//  KMLPlacemark.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

import AEXML
import Foundation

/// A Feature that is associated with a Geometry, and the main tool
/// in a KML file. A placemark includes a Geometry object, and any
/// descriptive information about it.
///
/// For reference, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#placemark)
public struct KMLPlacemark: KMLFeature {
    public var id: String?
    public var name: String?
    public var featureDescription: String?
    public var geometry: KMLGeometry

    public var styleUrl: KMLStyleUrl?
    public var style: KMLStyle?

    public static var featureType: KMLFeatureType {
        .placemark
    }

    public init(
        id: String? = nil,
        name: String,
        featureDescription: String? = nil,
        geometry: KMLGeometry,
        styleUrl: KMLStyleUrl? = nil,
        style: KMLStyle? = nil
    ) {
        self.id = id
        self.name = name
        self.featureDescription = featureDescription
        self.geometry = geometry
        self.styleUrl = styleUrl
        self.style = style
    }
}

// MARK: - KML Codable

extension KMLPlacemark: KMLCodableObject {
    init(xml: AEXMLElement) throws {
        try Self.verifyXmlTag(xml)
        self.id = xml.idAttribute
        self.name = xml.valueIfPresent(of: String.self, forKey: .name)
        self.featureDescription = xml.valueIfPresent(of: String.self, forKey: .description)

        guard let childGeometryType = KMLGeometryType
            .allCases
            .first(where: { xml[$0.rawValue].error == nil })
        else {
            throw KMLError.missingRequiredElement(elementName: "Geometry")
        }

        let childGeometry = try childGeometryType
            .concreteType
            .init(xml: xml[childGeometryType.rawValue])

        if let multiGeom = childGeometry as? KMLMultiGeometry,
           multiGeom.geometries.count == 1
        {
            self.geometry = multiGeom.geometries[0]
        } else {
            self.geometry = childGeometry
        }

        self.style = xml.children(of: KMLStyle.self).first
        self.styleUrl = xml.valueIfPresent(of: KMLStyleUrl.self, forKey: .styleUrl)
    }

    var children: [any KMLCodable] {
        geometry as? KMLCodableObject
        KMLValueElement(name: .styleUrl, value: styleUrl)
        style
    }
}

