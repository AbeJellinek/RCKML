//
//  KMLStyleMap.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

/// A wrapper around one or two KMLStyles to provide a standard and a highlighted version for a given Feature.
///
/// This implementation only contains the standard (non-highlighted) style option. The map can either contain
/// a KMLStyleUrl or a KMLStyle, but not both.
///
/// For definition, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#stylemap)
public struct KMLStyleMap: KMLStyleSelector {
    public var id: String?
    public var content: AnyKMLStyle

    public static var kmlTag: String {
        "StyleMap"
    }

    public init(
        id: String? = nil,
        styleUrl: KMLStyleUrl
    ) {
        self.id = id
        self.content = .styleUrl(styleUrl)
    }

    public init(
        id: String? = nil,
        style: KMLStyle
    ) {
        self.id = id
        self.content = .style(style)
    }
}

// MARK: - KML Codable

extension KMLStyleMap: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        let contentPair = Pair(key: .normal, content: content)
        try encoder.encodeChild(contentPair)
    }
}

extension KMLStyleMap: KMLDecodable {
    struct MissingPrimaryStyle: Error {}

    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute
        let pairs = decoder.children(of: KMLStyleMap.Pair.self)
        guard let primaryPair = pairs.first(where: { $0.key == .normal }) else {
            throw MissingPrimaryStyle()
        }
        content = primaryPair.content
    }
}

// MARK: - Internal Pair Type

fileprivate extension KMLTagName {
    static let pairKey = KMLTagName("key")
}

extension KMLStyleMap {
    struct Pair: KMLObject {
        enum StyleState: String {
            case normal
            case highlight
        }

        var id: String?
        var key: StyleState
        var content: AnyKMLStyle

        static var kmlTag: String { "Pair" }
    }
}

extension KMLStyleMap.Pair: KMLDecodable {
    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute
        key = try decoder.value(of: StyleState.self, forKey: .pairKey)
        content = try decoder.child(of: AnyKMLStyle.self)
    }
}

extension KMLStyleMap.Pair: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        try encoder.encode(tag: .pairKey, value: key.rawValue)
        switch content {
        case .style(let style):
            try encoder.encodeChild(style)
        case .styleUrl(let styleUrl):
            try encoder.encode(tag: .styleUrl, value: styleUrl)
        }
    }
}
