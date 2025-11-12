//
//  KMLMultiGeometry.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import AEXML
import Foundation

/// A geometry type representing a collection of other geometries.
///
/// For reference, see [KML Documentation](https://developers.google.com/kml/documentation/kmlreference#multigeometry)
public struct KMLMultiGeometry: KMLGeometry {
    public var id: String?
    public var geometries: [KMLGeometry]

    public static var geometryType: KMLGeometryType {
        .multiGeometry
    }

    public init(
        id: String? = nil,
        geometries: [KMLGeometry]
    ) {
        self.id = id
        self.geometries = geometries
    }
}

// MARK: KML Codable

extension KMLMultiGeometry: KMLCodableObject {
    init(xml: AEXMLElement) throws {
        try Self.verifyXmlTag(xml)
        geometries = try xml.children.compactMap { xmlChild -> KMLGeometry? in
            guard let type = KMLGeometryType(rawValue: xmlChild.name) else {
                return nil
            }
            let object = try type.concreteType.init(xml: xmlChild)
            return object
        }
    }

    var children: [any KMLCodable] {
        for aGeometry in geometries {
            aGeometry as? KMLCodableObject
        }
    }
}
