//
//  KMLFolder.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

/// A feature to be included in KML files, which can contain any number of other KML features, including sub-folders.
///
/// For reference, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#folder)
public struct KMLFolder: KMLFeature, KMLContainer {
    public var id: String?
    public var name: String?
    public var featureDescription: String?
    public var features: [AnyKMLFeature]

    public static var kmlTag: String {
        "Folder"
    }

    /// Initializes a `KMLFolder` with already-wrapped features.
    ///
    /// - Parameters:
    ///   - id: Optional identifier for the folder's KML element.
    ///   - name: Optional user-visible name for the folder.
    ///   - featureDescription: Optional description for the folder.
    ///   - features: An array of features already wrapped in `AnyKMLFeature`.
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

    /// Initializes a `KMLFolder` from raw feature protocol types.
    ///
    /// - Parameters:
    ///   - id: Optional identifier for the folder's KML element.
    ///   - name: Optional user-visible name for the folder.
    ///   - featureDescription: Optional description for the folder.
    ///   - features: An array of concrete feature values conforming to `KMLFeature`, which will be
    ///               wrapped into `AnyKMLFeature`.
    ///
    /// - Throws: `UnsupportedType` if any feature cannot be represented as `AnyKMLFeature`.
    public init(
        id: String? = nil,
        name: String? = nil,
        featureDescription: String? = nil,
        features: [any KMLFeature]
    ) throws {
        self.id = id
        self.name = name
        self.featureDescription = featureDescription
        self.features = try features.map(AnyKMLFeature.init)
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
        name = try? decoder.decode(String.self, forKey: .name)
        featureDescription = try? decoder.decode(String.self, forKey: .description)
        features = try decoder.decode([AnyKMLFeature].self)
    }
}
