//
//  KMLMultiGeometry.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

/// A geometry type representing a collection of other geometries.
///
/// For reference, see [KML Documentation](https://developers.google.com/kml/documentation/kmlreference#multigeometry)
public struct KMLMultiGeometry: KMLGeometry {
    public var id: String?
    public var geometries: [AnyKMLGeometry]

    public static var kmlTag: String {
        "MultiGeometry"
    }

    public init(
        id: String? = nil,
        geometries: [AnyKMLGeometry]
    ) {
        self.id = id
        self.geometries = geometries
    }
}

// MARK: KML Codable

extension KMLMultiGeometry: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        for geometry in geometries {
            try encoder.encodeChild(geometry)
        }
    }
}

extension KMLMultiGeometry: KMLDecodable {
    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute
        self.geometries = try decoder.decode([AnyKMLGeometry].self)
    }
}
