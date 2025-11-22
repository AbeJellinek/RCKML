//
//  KMLLineString.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

/// A series of KMLCoordinates connected in order to form  a line on the map.
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

    public static var kmlTag: String {
        "LineString"
    }
}

// MARK: KML Codable

extension KMLLineString: KMLDecodable {
    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute
        coordinates = try decoder.value(of: [KMLCoordinate].self, forKey: .coordinates)
    }
}

extension KMLLineString: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        try encoder.encode(tag: .coordinates, value: coordinates)
    }
}
