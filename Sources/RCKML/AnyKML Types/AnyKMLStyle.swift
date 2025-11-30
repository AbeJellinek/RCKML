//
//  AnyKMLStyle.swift
//  RCKML
//
//  Created by Ryan Linn on 11/30/25.
//

public enum AnyKMLStyle: AnyKML {
    case styleUrl(KMLStyleUrl)
    case style(KMLStyle)

    public var wrapped: Any {
        switch self {
        case .styleUrl(let styleUrl):
            styleUrl
        case .style(let style):
            style
        }
    }

    public init(_ wrapped: Any) throws(UnsupportedType) {
        switch wrapped {
        case let styleUrl as KMLStyleUrl:
            self = .styleUrl(styleUrl)
        case let style as KMLStyle:
            self = .style(style)
        default:
            throw UnsupportedType()
        }
    }
}

// MARK: - Encodable/Decodable

extension AnyKMLStyle: AnyDecodableKML, AnyEncodableKML {
    init(from decoder: KMLDecoder) throws {
        if decoder.tagName == KMLStyle.kmlTag {
            self = try .style(KMLStyle(from: decoder))
        } else if let styleUrl = try? decoder.as(KMLStyleUrl.self, forKey: .styleUrl) {
            self = .styleUrl(styleUrl)
        } else {
            throw UnsupportedType()
        }
    }

    var encodable: EncodingValueType {
        switch self {
        case .styleUrl(let styleUrl):
                .value(name: .styleUrl, value: styleUrl)
        case .style(let style):
                .object(style)
        }
    }
}
