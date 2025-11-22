//
//  KMLPlacemark.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

/// A Feature that is associated with a Geometry, and the main tool  in a KML file. A placemark includes a
/// Geometry object, and any  descriptive information about it.
///
/// For reference, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#placemark)
public struct KMLPlacemark: KMLFeature {
    public var id: String?
    public var name: String?
    public var featureDescription: String?
    public var geometry: AnyKMLGeometry
    public var style: AnyKMLStyle?

    public static var kmlTag: String {
        "Placemark"
    }

    public init(
        id: String? = nil,
        name: String,
        featureDescription: String? = nil,
        geometry: AnyKMLGeometry,
        styleUrl: KMLStyleUrl
    ) {
        self.id = id
        self.name = name
        self.featureDescription = featureDescription
        self.geometry = geometry
        self.style = .styleUrl(styleUrl)
    }

    public init(
        id: String? = nil,
        name: String,
        featureDescription: String? = nil,
        geometry: AnyKMLGeometry,
        style: KMLStyle
    ) {
        self.id = id
        self.name = name
        self.featureDescription = featureDescription
        self.geometry = geometry
        self.style = .style(style)
    }

    public init(
        id: String? = nil,
        name: String,
        featureDescription: String? = nil,
        geometry: AnyKMLGeometry
    ) {
        self.id = id
        self.name = name
        self.featureDescription = featureDescription
        self.geometry = geometry
        self.style = nil
    }
}

// MARK: - KML Codable

extension KMLPlacemark: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        try encoder.encode(tag: .name, value: name)
        try encoder.encode(tag: .description, value: featureDescription)
        try encoder.encodeChild(geometry)
        try encoder.encodeChild(style)
    }
}

extension KMLPlacemark: KMLDecodable {
    struct GeometryCountError: Error {
        var count: Int
    }

    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute
        name = try? decoder.value(of: String.self, forKey: .name)
        featureDescription = try? decoder.value(of: String.self, forKey: .description)

        style = try? decoder.child(of: AnyKMLStyle.self)

        // geometry:
        let geometries = try decoder.allChildren(of: AnyKMLGeometry.self)
        if geometries.count > 1 {
            throw GeometryCountError(count: geometries.count)
        }
        guard let geometry = geometries.first else {
            throw GeometryCountError(count: geometries.count)
        }
        self.geometry = geometry
    }
}
