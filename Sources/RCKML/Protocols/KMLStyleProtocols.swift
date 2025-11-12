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

typealias KMLCodableStyleSelector = (KMLStyleSelector & KMLCodableObject)

extension KMLStyleSelector {
    var encodable: KMLCodableStyleSelector? {
        self as? KMLCodableStyleSelector
    }
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
