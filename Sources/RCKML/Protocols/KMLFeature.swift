//
//  KMLFeature.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import AEXML
import Foundation

/// Any KMLObject type to be used in *Feature* objects of a KML document.
///
/// For definition, see [KML spec](https://developers.google.com/kml/documentation/kmlreference#feature)
public protocol KMLFeature: KMLObject {
    /// Type-level definition to map conforming type to a known KML Geometry class.
    static var featureType: KMLFeatureType { get }

    /// An optional user-visible name for the feature.
    var name: String? { get }

    /// An optional text description of the feature.
    var featureDescription: String? { get }
}

extension KMLFeature {
    public static var kmlTag: String {
        featureType.rawValue
    }
}

typealias KMLCodableFeature = (KMLFeature & KMLCodableObject)

// MARK: - Known Feature Types

/// Helper to map between Feature objects in a KML file and this library's corresponding `KMLFeature`
///
/// - Important: Whenever a Feature type is added to this library, you must also add a corresponding
/// case to this enum
public enum KMLFeatureType: String, CaseIterable {
    case folder = "Folder"
    case placemark = "Placemark"

    /// The RCKML type that corresponds to this KML feature class.
    var concreteType: KMLFeature.Type {
        switch self {
        case .folder:
            KMLFolder.self
        case .placemark:
            KMLPlacemark.self
        }
    }

    /// Tests whether an XML element is a recognized KML type for this library
    static func elementIsRecognizedType(_ xml: AEXMLElement) -> Bool {
        guard let type = KMLFeatureType(rawValue: xml.name) else {
            return false
        }

        if type == .placemark,
           xml.children.allSatisfy({ KMLGeometryType(rawValue: $0.name) == nil })
        {
            return false
        }

        return true
    }
}
