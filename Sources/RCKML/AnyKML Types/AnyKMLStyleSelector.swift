//
//  AnyKMLStyleSelector.swift
//  RCKML
//
//  Created by Ryan Linn on 11/30/25.
//

public enum AnyKMLStyleSelector: AnyKML {
    case styleMap(KMLStyleMap)
    case style(KMLStyle)

    public var wrapped: KMLStyleSelector {
        switch self {
        case .styleMap(let styleMap):
            styleMap
        case .style(let style):
            style
        }
    }

    public init(_ wrapped: KMLStyleSelector) throws(UnsupportedType) {
        switch wrapped {
        case let styleMap as KMLStyleMap:
            self = .styleMap(styleMap)
        case let style as KMLStyle:
            self = .style(style)
        default:
            throw UnsupportedType()
        }
    }
}

// MARK: - AnyKMLStyleSelector Codable

extension AnyKMLStyleSelector: AnyDecodableKML {
    init(from decoder: KMLDecoder) throws {
        switch decoder.tagName {
        case KMLStyleMap.kmlTag:
            self = try .styleMap(KMLStyleMap(from: decoder))
        case KMLStyle.kmlTag:
            self = try .style(KMLStyle(from: decoder))
        default:
            throw UnsupportedType()
        }
    }
}

extension AnyKMLStyleSelector: AnyEncodableKML {
    var encodable: EncodingValueType {
        switch self {
        case .styleMap(let styleMap):
                .object(styleMap)
        case .style(let style):
                .object(style)
        }
    }
}
