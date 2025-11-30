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
    public var normalStyle: AnyKMLStyle
    public var highlightStyle: AnyKMLStyle?

    public static var kmlTag: String {
        "StyleMap"
    }

    public init(id: String? = nil, normal: KMLStyleUrl, highlight: KMLStyleUrl?) {
        self.id = id
        self.normalStyle = .styleUrl(normal)
        self.highlightStyle = highlight.map { .styleUrl($0) }
    }

    public init(id: String? = nil, normal: KMLStyleUrl, highlight: KMLStyle?) {
        self.id = id
        self.normalStyle = .styleUrl(normal)
        self.highlightStyle = highlight.map { .style($0) }
    }

    public init(id: String? = nil, normal: KMLStyle, highlight: KMLStyleUrl?) {
        self.id = id
        self.normalStyle = .style(normal)
        self.highlightStyle = highlight.map { .styleUrl($0) }
    }

    public init(id: String? = nil, normal: KMLStyle, highlight: KMLStyle?) {
        self.id = id
        self.normalStyle = .style(normal)
        self.highlightStyle = highlight.map { .style($0) }
    }
}

// MARK: - KML Codable

extension KMLStyleMap: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        let normalPair = Pair(key: .normal, content: normalStyle)
        try encoder.encodeChild(normalPair)

        if let highlightStyle  {
            let highlightPair = Pair(key: .highlight, content: highlightStyle)
            try encoder.encodeChild(highlightPair)
        }
    }
}

extension KMLStyleMap: KMLDecodable {
    struct MissingPrimaryStyle: Error {}

    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute
        let pairs = try decoder.decode([KMLStyleMap.Pair].self)
        guard let primaryPair = pairs.first(where: { $0.key == .normal }) else {
            throw MissingPrimaryStyle()
        }
        normalStyle = primaryPair.content

        if let highlightPair = pairs.first(where: { $0.key == .highlight }) {
            highlightStyle = highlightPair.content
        }
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
        key = try decoder.decode(StyleState.self, forKey: .pairKey)
        content = try decoder.decode(AnyKMLStyle.self)
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
