//
//  KMLTag.swift
//  RCKML
//
//  Created by Ryan Linn on 11/6/25.
//

struct KMLTagName: ExpressibleByStringLiteral, Sendable, Hashable {
    var name: String

    public init(stringLiteral value: StringLiteralType) {
        self.name = value
    }

    static let name: Self = "name"
    static let description: Self = "description"
    static let coordinates: Self = "coordinates"
    static let styleUrl: Self = "styleUrl"
}
