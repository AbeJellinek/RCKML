//
//  AnyKMLFeature.swift
//  RCKML
//
//  Created by Ryan Linn on 11/30/25.
//

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

    public init(_ wrapped: any KMLFeature) throws(UnsupportedType) {
        switch wrapped {
        case let folder as KMLFolder:
            self = .folder(folder)
        case let placemark as KMLPlacemark:
            self = .placemark(placemark)
        default:
            throw UnsupportedType()
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
            throw UnsupportedType()
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
