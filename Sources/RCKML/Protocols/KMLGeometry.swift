//
//  KMLGeometry.swift
//  RCKML
//
//  Created by Ryan Linn on 6/16/21.
//

import AEXML
import Foundation

// MARK: - Geometry Protocol

/// Any KMLObject type to be used in *Geometry* objects of a KML document.
///
/// For definition, see [KML spec](https://developers.google.com/kml/documentation/kmlreference#geometry)
public protocol KMLGeometry: KMLObject {
    /// Type-level definition to map conforming type to a known KML Geometry class.
    static var geometryType: KMLGeometryType { get }
}

public extension KMLGeometry {
    static var kmlTag: String {
        geometryType.rawValue
    }
}

// MARK: - Known Geometry Types

/// Helper to map between Geometry objects in a KML file and this library's corresponding `KMLGeometry`.
public enum KMLGeometryType: String, CaseIterable {
    case lineString = "LineString"
    case polygon = "Polygon"
    case point = "Point"
    case multiGeometry = "MultiGeometry"

    /// The RCKML type that corresponds to this KML Geometry class.
    var concreteType: (KMLGeometry & KMLCodableObject).Type {
        switch self {
        case .lineString:
            KMLLineString.self
        case .polygon:
            KMLPolygon.self
        case .point:
            KMLPoint.self
        case .multiGeometry:
            KMLMultiGeometry.self
        }
    }
}
