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

extension KMLMultiGeometry: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        for geometry in geometries {
            let encodableGeometry = try SomeKMLGeometry(geometry)
            try encoder.encodeChild(encodableGeometry)
        }
    }
}

extension KMLMultiGeometry: KMLDecodable {
    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute

        let subGeometries = try decoder.allChildren(of: SomeKMLGeometry.self)
        self.geometries = subGeometries.map(\.wrapped)
    }
}
