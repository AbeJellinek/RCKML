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
}

public enum SomeKMLGeometry: SomeKML {
    case lineString(KMLLineString)
    case polygon(KMLPolygon)
    case point(KMLPoint)
    case multiGeometry(KMLMultiGeometry)

    public var wrapped: any KMLGeometry {
        switch self {
        case .lineString(let lineString):
            lineString
        case .polygon(let polygon):
            polygon
        case .point(let point):
            point
        case .multiGeometry(let multiGeometry):
            multiGeometry
        }
    }

    public init(_ wrapped: any KMLGeometry) throws(UnknownKMLType) {
        switch wrapped {
        case let lineString as KMLLineString:
            self = .lineString(lineString)
        case let polygon as KMLPolygon:
            self = .polygon(polygon)
        case let point as KMLPoint:
            self = .point(point)
        case let multiGeometry as KMLMultiGeometry:
            self = .multiGeometry(multiGeometry)
        default:
            throw UnknownKMLType()
        }
    }
}

extension SomeKMLGeometry: SomeDecodableKML {
    init(from decoder: KMLDecoder) throws {
        switch decoder.tagName {
        case KMLLineString.kmlTag:
            self = try .lineString(KMLLineString(from: decoder))
        case KMLPolygon.kmlTag:
            self = try .polygon(KMLPolygon(from: decoder))
        case KMLPoint.kmlTag:
            self = try .point(KMLPoint(from: decoder))
        case KMLMultiGeometry.kmlTag:
            self = try .multiGeometry(KMLMultiGeometry(from: decoder))
        default:
            throw UnknownKMLType()
        }
    }
}

extension SomeKMLGeometry: SomeEncodableKML {
    var encodable: EncodingValueType {
        switch self {
        case .lineString(let lineString):
            .object(lineString)
        case .polygon(let polygon):
            .object(polygon)
        case .point(let point):
            .object(point)
        case .multiGeometry(let multiGeometry):
            .object(multiGeometry)
        }
    }
}
