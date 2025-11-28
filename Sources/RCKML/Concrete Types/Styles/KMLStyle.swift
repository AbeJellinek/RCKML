//
//  KMLStyle.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

/// A wrapper around possible KML style types used to determine drawing behavior for an object, referenced
/// either inside a KMLFeature, or from a KMLStyleMap by its id.
///
/// A KMLStyle can contain up to one of each type of KMLColorStyle, plus ListStyle.
///
/// For definition, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#style)
public struct KMLStyle: KMLStyleSelector {
    public var id: String?
    public var lineStyle: KMLLineStyle?
    public var polyStyle: KMLPolyStyle?

    public var isEmpty: Bool {
        lineStyle?.color == nil && polyStyle?.color == nil
    }

    public static var kmlTag: String {
        "Style"
    }

    public init(
        id: String? = nil,
        lineStyle: KMLLineStyle? = nil,
        polyStyle: KMLPolyStyle? = nil
    ) {
        self.id = id
        self.lineStyle = lineStyle
        self.polyStyle = polyStyle
    }
}

// MARK: - KML Codable

extension KMLStyle: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        try encoder.encodeChild(lineStyle)
        try encoder.encodeChild(polyStyle)
    }
}

extension KMLStyle: KMLDecodable {
    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute
        lineStyle = try? decoder.decode(KMLLineStyle.self)
        polyStyle = try? decoder.decode(KMLPolyStyle.self)
    }
}
