//
//  KMLFolder.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

import AEXML
import Foundation

/// A feature to be included in KML files, which can contain any number of
/// other KML features, including sub-folders.
///
/// For reference, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#folder)
public struct KMLFolder: KMLFeature, KMLContainer {
    public var id: String?
    public var name: String?
    public var featureDescription: String?
    public var features: [KMLFeature]

    public static var featureType: KMLFeatureType {
        .folder
    }

    public init(
        id: String? = nil,
        name: String? = nil,
        featureDescription: String? = nil,
        features: [KMLFeature] = []
    ) {
        self.id = id
        self.name = name
        self.featureDescription = featureDescription
        self.features = features
    }
}

// MARK: - KMLObject

extension KMLFolder: KMLCodableObject {
    init(xml: AEXMLElement) throws {
        try Self.verifyXmlTag(xml)
        self.id = xml.idAttribute
        name = xml.valueIfPresent(of: String.self, forKey: .name)
        featureDescription = xml.valueIfPresent(of: String.self, forKey: .description)
        features = try Self.features(from: xml)
    }

    var children: [any KMLCodable] {
        encodableFeatures
    }
}
