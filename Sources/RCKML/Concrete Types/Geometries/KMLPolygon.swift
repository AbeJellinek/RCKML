//
//  KMLPolygon.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

import AEXML
import Foundation

/// A geometry representing an enclosed region, possibly including
/// inner boundaries as well.
///
/// For reference, see [KML Documentation](https://developers.google.com/kml/documentation/kmlreference#polygon)
public struct KMLPolygon: KMLGeometry {
    public var id: String?

    /// The outer boundary of the polygon.
    public var outerBoundaryIs: LinearRing

    /// An optional array of internal boundaries inside the
    /// polygon, which represent holes in the polygon.
    public var innerBoundaryIs: [LinearRing]?

    public static var geometryType: KMLGeometryType {
        .polygon
    }

    public init(
        id: String? = nil,
        outerBoundary: LinearRing,
        innerBoundaries: [LinearRing]? = nil
    ) {
        self.id = id
        outerBoundaryIs = outerBoundary
        innerBoundaryIs = innerBoundaries
    }
}

// MARK: KMLElement

fileprivate extension KMLTagName {
    static var outerBoundaryIs: Self { KMLTagName("outerBoundaryIs") }
    static var innerBoundaryIs: Self { KMLTagName("innerBoundaryIs") }
}

extension KMLPolygon: KMLDecodable {
    init(from container: KMLDecoder) throws {
        try container.verifyMatchesType(Self.self)
        id = container.idAttribute

        let outerBoundaryContainer = try container.subContainer(withName: .outerBoundaryIs)
        outerBoundaryIs = try outerBoundaryContainer.child(of: LinearRing.self)

        if let innerBoundsContainer = try? container.subContainer(withName: .innerBoundaryIs) {
            let decodedInnerBounds = innerBoundsContainer.children(of: LinearRing.self)
            if !decodedInnerBounds.isEmpty {
                innerBoundaryIs = decodedInnerBounds
            }
        }
    }
}

extension KMLPolygon: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        let outerBoundaryContainer = try encoder.addContainer(tag: .outerBoundaryIs)
        try outerBoundaryContainer.encodeChild(outerBoundaryIs)

        if let innerBoundaryIs, !innerBoundaryIs.isEmpty {
            let innerBoundaryContainer = try encoder.addContainer(tag: .innerBoundaryIs)
            for innerRing in innerBoundaryIs {
                try innerBoundaryContainer.encodeChild(innerRing)
            }
        }
    }
}

// MARK: - Linear Ring

extension KMLPolygon {
    /// A closed version of LineString, where the first
    /// and last points connect, forming an enclosed area.
    ///
    /// For reference, see [KML Documentation](https://developers.google.com/kml/documentation/kmlreference#linearring)
    public struct LinearRing: KMLObject {
        public var id: String?
        public var coordinates: [KMLCoordinate]

        public static var kmlTag: String {
            "LinearRing"
        }

        public init(
            id: String? = nil,
            coordinates: [KMLCoordinate]
        ) {
            self.id = id
            self.coordinates = coordinates
        }
    }
}

// MARK: KML Codable

extension KMLPolygon.LinearRing: KMLDecodable {
    init(from container: KMLDecoder) throws {
        try container.verifyMatchesType(Self.self)
        id = container.idAttribute
        coordinates = try container.value(of: [KMLCoordinate].self, forKey: .coordinates)
    }
}

extension KMLPolygon.LinearRing: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        try encoder.encode(tag: .coordinates, value: coordinates)
    }
}
