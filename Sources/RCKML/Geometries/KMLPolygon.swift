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

extension KMLPolygon: KMLCodableObject {
    private static var outerBoundaryKey: String { "outerBoundaryIs" }
    private static var innerBoundaryKey: String { "innerBoundaryIs" }

    init(xml: AEXMLElement) throws {
        // TODO: helper functions to clean this up
        try Self.verifyXmlTag(xml)

        let outerBoundsElement = try xml.requiredXmlChild(name: Self.outerBoundaryKey)
        let outerBoundsLineRing = try outerBoundsElement.firstChild(ofType: LinearRing.self)
        outerBoundaryIs = outerBoundsLineRing

        let innerBoundsElements = xml[Self.innerBoundaryKey]
            .children(of: LinearRing.self)

        if !innerBoundsElements.isEmpty {
            innerBoundaryIs = innerBoundsElements
        } else {
            innerBoundaryIs = nil
        }
    }

    var children: [any KMLCodable] {
        KMLNestedObject(tagName: Self.outerBoundaryKey, childObjects: [outerBoundaryIs])
        if let innerBoundaryIs {
            KMLNestedObject(tagName: Self.innerBoundaryKey, childObjects: innerBoundaryIs)
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

extension KMLPolygon.LinearRing: KMLCodableObject {
    init(xml: AEXMLElement) throws {
        try Self.verifyXmlTag(xml)
        coordinates = try xml.value(of: [KMLCoordinate].self, forKey: .coordinates)
    }

    var children: [any KMLCodable] {
        KMLValueElement(name: .coordinates, value: coordinates)
    }
}
