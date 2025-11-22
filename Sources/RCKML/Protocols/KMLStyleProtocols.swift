//
//  KMLStyle.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import AEXML
import Foundation

/// Protocol for conforming to the abstract KML element type *StyleSelector*,
/// which is the base type for *Style* and *StyleMap*.
///
/// For definition, see [KML spec](https://developers.google.com/kml/documentation/kmlreference#styleselector)
public protocol KMLStyleSelector: KMLObject {
    /// Identifier of the KML element, which can be set in order to read
    /// styles from the main body of the KML document via a *KMLStyleMap*
    var id: String? { get }
}

enum KMLStyleSelectorType: String, CaseIterable {
    case styleMap = "StyleMap"
    case style = "Style"
}

/// Protocol for conforming to the abstract KML element *ColorStyle*,
/// which is the base type for *LineStyle*, *PolyStyle*, *IconStyle*, and *LabelStyle*
///
/// For definition, see [KML spec](https://developers.google.com/kml/documentation/kmlreference#colorstyle)
public protocol KMLColorStyle: KMLObject {
    /// Identifier of the KML element, which can be set in order to read
    /// styles from the main body of the KML document via a *KMLStyleMap*
    var id: String? { get }
    /// The object representing the displayed color
    var color: KMLColor? { get }
}

public enum AnyKMLStyle {
    case styleUrl(KMLStyleUrl)
    case style(KMLStyle)
}

extension AnyKMLStyle: AnyDecodableKML, AnyEncodableKML {
    public var wrapped: Any {
        switch self {
        case .styleUrl(let styleUrl):
            styleUrl
        case .style(let style):
            style
        }
    }
    
    public init(_ wrapped: Any) throws(UnknownKMLType) {
        switch wrapped {
        case let styleUrl as KMLStyleUrl:
            self = .styleUrl(styleUrl)
        case let style as KMLStyle:
            self = .style(style)
        default:
            throw UnknownKMLType()
        }
    }

    struct MissingStyle: Error {}

    init(from decoder: KMLDecoder) throws {
        if let style = try? decoder.child(of: KMLStyle.self) {
            self = .style(style)
        } else if let styleUrl = try? decoder.value(of: KMLStyleUrl.self, forKey: .styleUrl) {
            self = .styleUrl(styleUrl)
        } else {
            throw MissingStyle()
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

    public init(_ wrapped: KMLStyleSelector) throws(UnknownKMLType) {
        switch wrapped {
        case let styleMap as KMLStyleMap:
            self = .styleMap(styleMap)
        case let style as KMLStyle:
            self = .style(style)
        default:
            throw UnknownKMLType()
        }
    }
}

extension AnyKMLStyleSelector: AnyDecodableKML {
    init(from decoder: KMLDecoder) throws {
        switch decoder.tagName {
        case KMLStyleMap.kmlTag:
            self = try .styleMap(KMLStyleMap(from: decoder))
        case KMLStyle.kmlTag:
            self = try .style(KMLStyle(from: decoder))
        default:
            throw UnknownKMLType()
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
