//
//  KMLFeature.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import Foundation

/// Any KMLObject type to be used in *Feature* objects of a KML document.
///
/// For definition, see [KML spec](https://developers.google.com/kml/documentation/kmlreference#feature)
public protocol KMLFeature: KMLObject {
    /// An optional user-visible name for the feature.
    var name: String? { get }

    /// An optional text description of the feature.
    var featureDescription: String? { get }
}

// MARK: - AnyKMLFeature

public enum AnyKMLFeature: AnyKML {
    case placemark(KMLPlacemark)
    case folder(KMLFolder)

    public var wrapped: any KMLFeature {
        switch self {
        case .placemark(let placemark):
            placemark
        case .folder(let folder):
            folder
        }
    }

    public init(_ wrapped: any KMLFeature) throws(UnknownKMLType) {
        switch wrapped {
        case let folder as KMLFolder:
            self = .folder(folder)
        case let placemark as KMLPlacemark:
            self = .placemark(placemark)
        default:
            throw UnknownKMLType()
        }
    }
}

// MARK: - AnyKMLFeature Codable

extension AnyKMLFeature: AnyDecodableKML {
    init(from decoder: KMLDecoder) throws {
        switch decoder.tagName {
        case KMLFolder.kmlTag:
            self = try .folder(KMLFolder(from: decoder))
        case KMLPlacemark.kmlTag:
            self = try .placemark(KMLPlacemark(from: decoder))
        default:
            throw UnknownKMLType()
        }
    }
}

extension AnyKMLFeature: AnyEncodableKML {
    var encodable: EncodingValueType {
        switch self {
        case .placemark(let placemark):
            .object(placemark)
        case .folder(let folder):
            .object(folder)
        }
    }
}
