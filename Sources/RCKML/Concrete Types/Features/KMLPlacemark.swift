//
//  KMLPlacemark.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

/// A Feature that is associated with a Geometry, and the primary feature type in a KML file. A placemark
/// includes a Geometry object and any descriptive information about it.
///
/// For reference, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#placemark)
public struct KMLPlacemark: KMLFeature {
    public var id: String?
    public var name: String?
    public var featureDescription: String?
    public var geometry: AnyKMLGeometry?
    public var style: AnyPlacemarkStyle?

    public static var kmlTag: String {
        "Placemark"
    }

    public init(
        id: String? = nil,
        name: String?,
        featureDescription: String? = nil,
        geometry: AnyKMLGeometry?,
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
        name: String?,
        featureDescription: String? = nil,
        geometry: AnyKMLGeometry?,
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
        name: String?,
        featureDescription: String? = nil,
        geometry: AnyKMLGeometry?,
        styleMap: KMLStyleMap
    ) {
        self.id = id
        self.name = name
        self.featureDescription = featureDescription
        self.geometry = geometry
        self.style = .styleMap(styleMap)
    }

    public init(
        id: String? = nil,
        name: String?,
        featureDescription: String? = nil,
        geometry: AnyKMLGeometry?
    ) {
        self.id = id
        self.name = name
        self.featureDescription = featureDescription
        self.geometry = geometry
        self.style = nil
    }
}

// MARK: - Placemark Style

extension KMLPlacemark {
    /// A type-erasing wrapper for the types of Style that can be used in a Placemark -- either a direct style
    /// using `KMLStyle` or `KMLStyleMap`, or a reference to a shared style using `KMLStyleUrl`.
    public enum AnyPlacemarkStyle: AnyKML {
        case styleMap(KMLStyleMap)
        case style(KMLStyle)
        case styleUrl(KMLStyleUrl)

        public var wrapped: Any {
            switch self {
            case .styleMap(let map):
                map
            case .style(let style):
                style
            case .styleUrl(let url):
                url
            }
        }

        public init(_ wrapped: Any) throws(UnsupportedType) {
            switch wrapped {
            case let styleUrl as KMLStyleUrl:
                self = .styleUrl(styleUrl)
            case let style as KMLStyle:
                self = .style(style)
            case let map as KMLStyleMap:
                self = .styleMap(map)
            default:
                throw UnsupportedType()
            }
        }
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
    struct GeometryCountError: Error, Equatable {
        var count: Int
    }

    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute
        name = try? decoder.decode(String.self, forKey: .name)
        featureDescription = try? decoder.decode(String.self, forKey: .description)

        style = try? decoder.decode(AnyPlacemarkStyle.self)

        // geometry:
        let geometries = try decoder.decode([AnyKMLGeometry].self)
        if geometries.count > 1 {
            throw GeometryCountError(count: geometries.count)
        }
        self.geometry = geometries.first
    }
}

extension KMLPlacemark.AnyPlacemarkStyle: AnyEncodableKML {
    var encodable: EncodingValueType {
        switch self {
        case .styleMap(let map):
                .object(map)
        case .styleUrl(let styleUrl):
                .value(name: .styleUrl, value: styleUrl)
        case .style(let style):
                .object(style)
        }
    }
}

extension KMLPlacemark.AnyPlacemarkStyle: AnyDecodableKML {
    init(from decoder: KMLDecoder) throws {
        if decoder.tagName == KMLStyleMap.kmlTag {
            self = try .styleMap(KMLStyleMap(from: decoder))
        } else if decoder.tagName == KMLStyle.kmlTag {
            self = try .style(KMLStyle(from: decoder))
        } else if let styleUrl = try? decoder.as(KMLStyleUrl.self, forKey: .styleUrl) {
            self = .styleUrl(styleUrl)
        } else {
            throw UnsupportedType()
        }
    }
}
