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
/// For reference, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#document)
public struct KMLDocument: KMLContainer {
    public struct UnidentifiedStyleError: Error {}

    public var id: String?
    public var name: String?
    public var featureDescription: String?
    public var features: [AnyKMLFeature]
    public var styles: [String : AnyKMLStyleSelector]

    public static var kmlTag: String {
        "Document"
    }

    /// Initializes a `KMLDocument` with already-wrapped features and styles.
    ///
    /// - Parameters:
    ///   - id: Optional identifier for the document's KML element.
    ///   - name: Optional user-visible name for the document.
    ///   - featureDescription: Optional description of the document.
    ///   - features: An array of features already wrapped in `AnyKMLFeature`.
    ///   - styles: An array of style selectors already wrapped in `AnyKMLStyleSelector`.
    ///
    /// - Throws: `UnidentifiedStyleError` if any style selector in `styles` has no `id` value.
    public init(
        id: String? = nil,
        name: String? = nil,
        featureDescription: String? = nil,
        features: [AnyKMLFeature] = [],
        styles: [AnyKMLStyleSelector] = []
    ) throws(UnidentifiedStyleError) {
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
                throw UnidentifiedStyleError()
            }
        }
        self.styles = identifiedStyles
    }

    /// Initializes a `KMLDocument` from raw feature and style selector protocol types.
    ///
    /// - Parameters:
    ///   - id: Optional identifier for the document's KML element.
    ///   - name: Optional user-visible name for the document.
    ///   - featureDescription: Optional description of the document.
    ///   - features: An array of features already wrapped in `AnyKMLFeature`.
    ///   - styles: An array of style selectors conforming to `KMLStyleSelector`, which will be
    ///             wrapped into `AnyKMLStyleSelector`.
    ///
    /// - Throws:
    ///   - `UnsupportedType` if any style selector cannot be represented as `AnyKMLStyleSelector`.
    ///   - `UnidentifiedStyleError` if any style selector in `styles` has no `id` value.
    public init(
        id: String? = nil,
        name: String? = nil,
        featureDescription: String? = nil,
        features: [AnyKMLFeature] = [],
        styles: [any KMLStyleSelector]
    ) throws {
        let anyStyles = try styles.map(AnyKMLStyleSelector.init)
        try self.init(
            id: id,
            name: name,
            featureDescription: featureDescription,
            features: features,
            styles: anyStyles
        )
    }

    /// Initializes a `KMLDocument` from raw feature protocol types and already-wrapped styles.
    ///
    /// - Parameters:
    ///   - id: Optional identifier for the document's KML element.
    ///   - name: Optional user-visible name for the document.
    ///   - featureDescription: Optional description of the document.
    ///   - features: An array of concrete feature values conforming to `KMLFeature`, which will be
    ///               wrapped into `AnyKMLFeature`.
    ///   - styles: An array of style selectors already wrapped in `AnyKMLStyleSelector`.
    ///
    /// - Throws:
    ///   - `UnsupportedType` if any feature cannot be represented as `AnyKMLFeature`.
    ///   - `UnidentifiedStyleError` if any style selector in `styles` has no `id` value.
    public init(
        id: String? = nil,
        name: String? = nil,
        featureDescription: String? = nil,
        features: [any KMLFeature],
        styles: [AnyKMLStyleSelector] = []
    ) throws {
        let anyFeatures = try features.map(AnyKMLFeature.init)
        try self.init(
            id: id,
            name: name,
            featureDescription: featureDescription,
            features: anyFeatures,
            styles: styles
        )
    }

    /// Initializes a `KMLDocument` from raw feature and style selector protocol types.
    ///
    /// - Parameters:
    ///   - id: Optional identifier for the document's KML element.
    ///   - name: Optional user-visible name for the document.
    ///   - featureDescription: Optional description of the document.
    ///   - features: An array of concrete feature values conforming to `KMLFeature`, which will be
    ///               wrapped into `AnyKMLFeature`.
    ///   - styles: An array of style selectors conforming to `KMLStyleSelector`, which will be
    ///             wrapped into `AnyKMLStyleSelector`.
    ///
    /// - Throws:
    ///   - `UnsupportedType` if any feature or style selector cannot be represented as the
    ///     corresponding `AnyKML*` wrapper type.
    ///   - `UnidentifiedStyleError` if any style selector in `styles` has no `id` value.
    public init(
        id: String? = nil,
        name: String? = nil,
        featureDescription: String? = nil,
        features: [any KMLFeature],
        styles: [any KMLStyleSelector]
    ) throws {
        let anyStyles = try styles.map(AnyKMLStyleSelector.init)
        let anyFeatures = try features.map(AnyKMLFeature.init)
        try self.init(
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

        try self.init(
            id: id,
            name: name,
            featureDescription: featureDescription,
            features: features,
            styles: styles
        )
    }
}
