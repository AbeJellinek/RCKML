//
//  KMLContainer.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

/// Any KMLObject that can contain one or more sub-element KMLFeatures.
///
/// For definition, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#container)
public protocol KMLContainer: KMLFeature {
    /// An array of all contained KMLFeatures in this container.
    var features: [AnyKMLFeature] { get }
}
