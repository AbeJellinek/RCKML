//
//  AnyKMLFeature.swift
//  RCKML
//
//  Created by Ryan Linn on 11/30/25.
//

/// A type-erasing wrapper for `KMLFeature` values, restricting them to the concrete Feature types in the
/// KML language -- Placemark, Folder, and Document.
///
/// `AnyKMLFeature` is used in `KMLFile`, `KMLDocument`, and `KMLContainer` types to provide
/// access to the contained Features.
public enum AnyKMLFeature: AnyKML {
    case placemark(KMLPlacemark)
    case folder(KMLFolder)
    case document(KMLDocument)

    public var wrapped: any KMLFeature {
        switch self {
        case .placemark(let placemark):
            placemark
        case .folder(let folder):
            folder
        case .document(let document):
            document
        }
    }

    public init(_ wrapped: any KMLFeature) throws(UnsupportedType) {
        switch wrapped {
        case let folder as KMLFolder:
            self = .folder(folder)
        case let placemark as KMLPlacemark:
            self = .placemark(placemark)
        case let document as KMLDocument:
            self = .document(document)
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
        case KMLDocument.kmlTag:
            self = try .document(KMLDocument(from: decoder))
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
        case .document(let document):
                .object(document)
        }
    }
}
