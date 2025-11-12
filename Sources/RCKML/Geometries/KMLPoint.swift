//
//  KMLPoint.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

import AEXML
import Foundation

/// A KML geometry associated with a single point on the Earth.
///
/// For reference, see [KML Documentation](https://developers.google.com/kml/documentation/kmlreference#point)
public struct KMLPoint: KMLGeometry {
    public var id: String?
    public var coordinate: KMLCoordinate

    public static var geometryType: KMLGeometryType {
        .point
    }

    public init(coordinate: KMLCoordinate) {
        self.coordinate = coordinate
    }

    public init(
        id: String? = nil,
        latitude: Double,
        longitude: Double,
        altitude: Double? = nil
    ) {
        self.id = id
        coordinate = KMLCoordinate(latitude: latitude, longitude: longitude, altitude: altitude)
    }
}

// MARK: KML Codable

extension KMLPoint: KMLCodableObject {
    init(xml: AEXMLElement) throws {
        try Self.verifyXmlTag(xml)
        self.id = xml.idAttribute
        self.coordinate = try xml.value(of: KMLCoordinate.self, forKey: .coordinates)
    }

    var children: [any KMLCodable] {
        KMLValueElement(name: .coordinates, value: coordinate)
    }
}
