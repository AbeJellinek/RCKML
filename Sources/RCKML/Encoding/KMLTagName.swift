//
//  KMLTag.swift
//  RCKML
//
//  Created by Ryan Linn on 11/6/25.
//

struct KMLTagName: Sendable, Hashable {
    var name: String

    init(_ name: String) {
        self.name = name
    }

    static let name = KMLTagName("name")
    static let description = KMLTagName("description")
    static let coordinates = KMLTagName("coordinates")
    static let styleUrl = KMLTagName("styleUrl")
    static let color = KMLTagName("color")
    static let width = KMLTagName("width")
}
