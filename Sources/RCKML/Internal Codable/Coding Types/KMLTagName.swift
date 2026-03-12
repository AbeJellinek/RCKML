//
//  KMLTagName.swift
//  RCKML
//
//  Created by Ryan Linn on 11/6/25.
//

/// A wrapper around a String, used to identify nested value elements in a KML object.
///
/// For example, in the following KML object, `name` and `description` are `KMLTagName`s:
///
/// ```
/// <Feature id="feature1">
///    <name>First Feature</name>
///    <description>This is a KML Feature</description>
///    <Placemark>
///        ....
///    </Placemark>
/// </Feature>
/// ```
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
    static let when = KMLTagName("when")
    static let gxCoord = KMLTagName("gx:coord")
}
