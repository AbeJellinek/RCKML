//
//  KMLPolygon.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

/// A geometry representing an enclosed region, possibly including inner cut-out boundaries as well.
///
/// For reference, see [KML Documentation](https://developers.google.com/kml/documentation/kmlreference#polygon)
public struct KMLPolygon: KMLGeometry {
    public var id: String?

    /// The outer boundary of the polygon.
    public var outerBoundaryIs: LinearRing

    /// An optional array of internal boundaries inside the polygon, which represent holes in the polygon.
    public var innerBoundaryIs: [LinearRing]?

    public static var kmlTag: String {
        "Polygon"
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

// MARK: - Linear Ring

extension KMLPolygon {
    /// A closed version of LineString, where the first and last points connect, forming an enclosed area.
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
        ) throws(RequirementViolation) {
            guard coordinates.count >= 4 else {
                throw .tooFewCoordinates
            }
            guard coordinates.first == coordinates.last else {
                throw .unclosedRing
            }
            // TODO: Require counterclockwise coordinates

            self.id = id
            self.coordinates = coordinates
        }
    }
}

// MARK: - KML Codable - Polygon

private extension KMLTagName {
    static var outerBoundaryIs: Self { KMLTagName("outerBoundaryIs") }
    static var innerBoundaryIs: Self { KMLTagName("innerBoundaryIs") }
}

extension KMLPolygon: KMLDecodable {
    init(from container: KMLDecoder) throws {
        try container.verifyMatchesType(Self.self)
        id = container.idAttribute

        let outerBoundaryContainers = container.decodeUntyped(named: .outerBoundaryIs)
        guard let outerBoundaryElement = outerBoundaryContainers.first else {
            throw KMLDecoderError.childTypeNotFound(expected: "outerBoundaryIs")
        }
        outerBoundaryIs = try outerBoundaryElement.decode(LinearRing.self)

        let innerBoundaryContainers = container.decodeUntyped(named: .innerBoundaryIs)
        let innerBoundaries = try innerBoundaryContainers.map { container in
            try container.decode(LinearRing.self)
        }
        if !innerBoundaries.isEmpty {
            innerBoundaryIs = innerBoundaries
        }
    }
}

extension KMLPolygon: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        let outerBoundaryContainer = try encoder.encodeContainer(tag: .outerBoundaryIs)
        try outerBoundaryContainer.encodeChild(outerBoundaryIs)

        if let innerBoundaryIs, !innerBoundaryIs.isEmpty {
            for innerRing in innerBoundaryIs {
                let innerBoundaryContainer = try encoder.encodeContainer(tag: .innerBoundaryIs)
                try innerBoundaryContainer.encodeChild(innerRing)
            }
        }
    }
}

// MARK: - LinearRing Requirement Violations

extension KMLPolygon.LinearRing {
    public enum RequirementViolation: Error {
        /// LinearRing requires 4 or more coordinates
        case tooFewCoordinates

        /// LinearRing requires that first and last coordinate are equal
        case unclosedRing

        /// Polygon requires that LinearRing coordinates are laid out counterclockwise
        ///
        /// This requirement is not currently implemented in this library.
        case clockwiseCoordinates
    }
}

// MARK: - KML Codable - LinearRing

extension KMLPolygon.LinearRing: KMLDecodable {
    init(from container: KMLDecoder) throws {
        try container.verifyMatchesType(Self.self)
        let id = container.idAttribute
        let coordinates = try container.decode([KMLCoordinate].self, forKey: .coordinates)
        try self.init(id: id, coordinates: coordinates)
    }
}

extension KMLPolygon.LinearRing: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        try encoder.encode(tag: .coordinates, value: coordinates)
    }
}
