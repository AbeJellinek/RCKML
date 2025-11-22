//
//  KMLObject.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

/// Any type of element found in a KML file, as described in the
/// [KML specification](https://developers.google.com/kml/documentation/kmlreference#object)
/// or [OGC KML Standard](https://www.ogc.org/standards/kml/)
///
/// The basic functions of this protocol are to provide encoding and decoding support
/// to a class or type of KML Element (for example, **Feature**, **Geometry**, or **Style**).
public protocol KMLObject {
    /// The XML element name for this type of KML Object, such as **Folder**, **Document**,
    /// **Geometry**, **Style**, etc.
    static var kmlTag: String { get }

    var id: String? { get }
}
