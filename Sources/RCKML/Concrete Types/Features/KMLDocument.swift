//
//  KMLDocument.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import AEXML
import Foundation
import ZIPFoundation

/// A container for Features and Styles, usually at the root of the KML file.
///
/// /// For reference, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#document)
public struct KMLDocument: KMLContainer {
    public var id: String?
    public var name: String?
    public var featureDescription: String?
    public var features: [AnyKMLFeature]
    public var styles: [String : AnyKMLStyleSelector]

    public static var kmlTag: String {
        "Document"
    }

    public init(
        id: String? = nil,
        name: String? = nil,
        featureDescription: String? = nil,
        features: [AnyKMLFeature] = [],
        styles: [AnyKMLStyleSelector] = []
    ) {
        self.id = id
        self.name = name
        self.featureDescription = featureDescription
        self.features = features

        var identifiedStyles = [String : AnyKMLStyleSelector]()
        for aStyleSelector in styles {
            if let styleId = aStyleSelector.wrapped.id {
                identifiedStyles[styleId] = aStyleSelector
            } else {
                // Document styles must have an ID
            }
        }
        self.styles = identifiedStyles
    }

    public init(
        id: String? = nil,
        name: String? = nil,
        featureDescription: String? = nil,
        features: [AnyKMLFeature] = [],
        styles: [any KMLStyleSelector]
    ) throws {
        let anyStyles = try styles.map(AnyKMLStyleSelector.init)
        self.init(
            id: id,
            name: name,
            featureDescription: featureDescription,
            features: features,
            styles: anyStyles
        )
    }

    public init(
        id: String? = nil,
        name: String? = nil,
        featureDescription: String? = nil,
        features: [any KMLFeature],
        styles: [AnyKMLStyleSelector] = []
    ) throws {
        let anyFeatures = try features.map(AnyKMLFeature.init)
        self.init(
            id: id,
            name: name,
            featureDescription: featureDescription,
            features: anyFeatures,
            styles: styles
        )
    }

    public init(
        id: String? = nil,
        name: String? = nil,
        featureDescription: String? = nil,
        features: [any KMLFeature],
        styles: [any KMLStyleSelector]
    ) throws {
        let anyStyles = try styles.map(AnyKMLStyleSelector.init)
        let anyFeatures = try features.map(AnyKMLFeature.init)
        self.init(
            id: id,
            name: name,
            featureDescription: featureDescription,
            features: anyFeatures,
            styles: anyStyles
        )
    }
}

// MARK: - Encoding

extension KMLDocument: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        try encoder.encode(tag: .name, value: name)
        try encoder.encode(tag: .description, value: featureDescription)
        for feature in features {
            try encoder.encodeChild(feature)
        }
        for styleSelector in styles.values {
            try encoder.encodeChild(styleSelector)
        }
    }
}

// MARK: - Decoding

extension KMLDocument: KMLDecodable {
    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        let id = decoder.idAttribute
        let name = try? decoder.decode(String.self, forKey: .name)
        let featureDescription = try? decoder.decode(String.self, forKey: .description)
        let features = try decoder.decode([AnyKMLFeature].self)
        let styles = try decoder.decode([AnyKMLStyleSelector].self)

        self.init(
            id: id,
            name: name,
            featureDescription: featureDescription,
            features: features,
            styles: styles
        )
    }
}
