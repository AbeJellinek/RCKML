//
//  KMLLineStyle.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

/// A style used to draw lines or polygon boundaries with a given width and color.
///
/// For definition, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#linestyle)
public struct KMLLineStyle: KMLColorStyle {
    public var id: String?
    public var width: Double
    public var color: KMLColor?

    public static var kmlTag: String {
        "LineStyle"
    }

    public init(
        id: String? = nil,
        width: Double = 1.0,
        color: KMLColor? = nil
    ) {
        self.id = id
        self.width = width
        self.color = color
    }
}

// MARK: - KML Codable

extension KMLLineStyle: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        try encoder.encode(tag: .width, value: width)
        try encoder.encode(tag: .color, value: color)
    }
}

extension KMLLineStyle: KMLDecodable {
    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute
        width = decoder.value(of: Double.self, forKey: .width, default: 1.0)
        color = try decoder.value(of: KMLColor.self, forKey: .color)
    }
}
