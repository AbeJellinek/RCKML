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

    /// Initializes an empty `KMLMultiGeometry` with an optional identifier.
    ///
    /// - Parameter id: Optional identifier for the geometry's KML element.
    public init(id: String? = nil) {
        self.id = id
        self.geometries = []
    }

    public init(
        id: String? = nil,
        geometries: [AnyKMLGeometry]
    ) {
        self.id = id
        self.geometries = geometries
    }

    /// Initializes a `KMLMultiGeometry` from raw geometry protocol types.
    ///
    /// - Parameters:
    ///   - id: Optional identifier for the geometry's KML element.
    ///   - geometries: An array of concrete geometry values conforming to `KMLGeometry`, which will be
    ///                 wrapped into `AnyKMLGeometry`.
    ///
    /// - Throws: `UnsupportedType` if any geometry cannot be represented as `AnyKMLGeometry`.
    public init(
        id: String? = nil,
        geometries: [any KMLGeometry]
    ) throws {
        self.id = id
        self.geometries = try geometries.map(AnyKMLGeometry.init)
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
