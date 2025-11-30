//
//  KMLStyle.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

// MARK: - StyleSelector

/// Protocol for conforming to the abstract KML element type *StyleSelector*, which is the base type for
/// *Style* and *StyleMap*.
///
/// For definition, see [KML spec](https://developers.google.com/kml/documentation/kmlreference#styleselector)
public protocol KMLStyleSelector: KMLObject {
    // No specific requirements
}

// MARK: - ColorStyle

/// Protocol for conforming to the abstract KML element *ColorStyle*,  which is the base type for
/// *LineStyle*, *PolyStyle*, *IconStyle*, and *LabelStyle*
///
/// For definition, see [KML spec](https://developers.google.com/kml/documentation/kmlreference#colorstyle)
public protocol KMLColorStyle: KMLObject {
    /// Identifier of the KML element, which can be set in order to read
    /// styles from the main body of the KML document via a *KMLStyleMap*
    var id: String? { get }
    /// The object representing the displayed color
    var color: KMLColor? { get }
}
