//
//  KMLLineString.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

import AEXML
import Foundation

/// A series of KMLCoordinates connected in order to form
/// a line on the map.
///
/// For reference, see [KML Documentation](https://developers.google.com/kml/documentation/kmlreference#linestring)
public struct KMLLineString: KMLGeometry {
    public var id: String?
    public var coordinates: [KMLCoordinate]

    public init(
        id: String? = nil,
        coordinates: [KMLCoordinate]
    ) {
        self.id = id
        self.coordinates = coordinates
    }

    public static var geometryType: KMLGeometryType {
        .lineString
    }
}

// MARK: KML Codable

extension KMLLineString: KMLCodableObject {
    init(xml: AEXMLElement) throws {
        try Self.verifyXmlTag(xml)
        coordinates = try xml.value(of: [KMLCoordinate].self, forKey: .coordinates)
    }

    var children: [any KMLCodable] {
        KMLValueElement(name: .coordinates, value: coordinates)
    }
}
