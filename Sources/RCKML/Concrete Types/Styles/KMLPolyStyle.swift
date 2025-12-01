//
//  KMLPolyStyle.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

/// A style used to determine fill color and whether to draw the outline of a polygon.
///
/// For definition, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#polystyle)
public struct KMLPolyStyle: KMLColorStyle {
    public var id: String?
    public var isFilled: Bool
    public var isOutlined: Bool
    public var color: KMLColor?

    public static var kmlTag: String {
        "PolyStyle"
    }

    public init(
        id: String? = nil,
        isFilled: Bool = false,
        isOutlined: Bool = true,
        color: KMLColor? = nil
    ) {
        self.id = id
        self.isFilled = isFilled
        self.isOutlined = isOutlined
        self.color = color
    }
}

// MARK: - KML Codable

private extension KMLTagName {
    static let isFilled = KMLTagName("fill")
    static let isOutlined = KMLTagName("outline")
}

extension KMLPolyStyle: KMLDecodable {
    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute
        color = try? decoder.decode(KMLColor.self, forKey: .color)
        isFilled = decoder.decode(Bool.self, forKey: .isFilled, default: false)
        isOutlined = decoder.decode(Bool.self, forKey: .isOutlined, default: true)
    }
}

extension KMLPolyStyle: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        try encoder.encode(tag: .color, value: color)
        try encoder.encode(tag: .isFilled, value: isFilled)
        try encoder.encode(tag: .isOutlined, value: isOutlined)
    }
}
