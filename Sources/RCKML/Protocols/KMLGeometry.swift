//
//  KMLGeometry.swift
//  RCKML
//
//  Created by Ryan Linn on 6/16/21.
//

// MARK: - Geometry Protocol

/// Any KMLObject type to be used in *Geometry* objects of a KML document.
///
/// For definition, see [KML spec](https://developers.google.com/kml/documentation/kmlreference#geometry)
public protocol KMLGeometry: KMLObject {
    // No specific requirements
}

// MARK: - AnyKMLGeometry

public enum AnyKMLGeometry: AnyKML {
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

// MARK: - AnyKMLGeometry Codable

extension AnyKMLGeometry: AnyDecodableKML {
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

extension AnyKMLGeometry: AnyEncodableKML {
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
