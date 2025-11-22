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
    public var features: [AnyKMLFeature]

    public static var featureType: KMLFeatureType {
        .folder
    }

    public init(
        id: String? = nil,
        name: String? = nil,
        featureDescription: String? = nil,
        features: [AnyKMLFeature] = []
    ) {
        self.id = id
        self.name = name
        self.featureDescription = featureDescription
        self.features = features
    }
}

// MARK: - KML Coding

extension KMLFolder: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        try encoder.encode(tag: .name, value: name)
        try encoder.encode(tag: .description, value: featureDescription)
        for feature in features {
            try encoder.encodeChild(feature)
        }
    }
}

extension KMLFolder: KMLDecodable {
    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute
        name = try decoder.value(of: String.self, forKey: .name)
        featureDescription = try decoder.value(of: String.self, forKey: .description)
        features = try decoder.allChildren(of: AnyKMLFeature.self)
    }
}
