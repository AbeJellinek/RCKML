//
//  KMLContainer.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import AEXML
import Foundation

/// Any KMLObject that can contain one or more sub-element KMLFeatures.
///
/// For definition, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#container)
public protocol KMLContainer: KMLObject {
    /// An array of all contained KMLFeatures in this container.
    var features: [SomeKMLFeature] { get }
}

// MARK: - Default Functions

public extension KMLContainer {
    /// An unordered array of all KMLFolders in this container,
    /// not counting those inside nested containers.
    var folders: [KMLFolder] {
        features.compactMap { $0.wrapped as? KMLFolder }
    }

    /// An unordered array of all KMLPlacemarks in this container,
    /// not counting those inside nested containers.
    var placemarks: [KMLPlacemark] {
        features.compactMap { $0.wrapped as? KMLPlacemark }
    }

    /// An array of all KMLPlacemarks in this container, as well as
    /// inside nested containers to any depth.
    var placemarksRecursive: [KMLPlacemark] {
        features.reduce(into: [KMLPlacemark]()) { result, feature in
            if let placemark = feature.wrapped as? KMLPlacemark {
                result.append(placemark)
            } else if let subContainer = feature.wrapped as? KMLContainer {
                result.append(contentsOf: subContainer.placemarksRecursive)
            }
        }
    }

    /// Finds the first item in this container with a given name.
    /// Nested containers are not searched.
    ///
    /// - Parameter itemName: The name of the item to be found
    /// - Returns: A KMLFeature with the given name, or nil if none exists.
    func getItemNamed(_ itemName: String) -> KMLFeature? {
        features.first(where: { $0.wrapped.name == itemName })?.wrapped
    }
}

// MARK: - Internal Functions

extension KMLContainer {
    /// For debug use, prints a string representation of all items inside this container
    /// - Parameter indentation: The indentation level of elements described.
    /// Only to be used inside this function call for recursive indentation.
    func listContents(indentation: Int = 0) {
        for feature in features {
            var basic = "\(String(repeating: ".", count: indentation))\(feature.wrapped.name): \(String(describing: type(of: feature.wrapped)))"

            if let placemark = feature.wrapped as? KMLPlacemark {
                basic += "-" + String(describing: type(of: placemark.geometry))
            } else if let folder = feature.wrapped as? KMLFolder {
                basic += " (\(folder.features.count) items)"
            }

            print(basic)
            if let folder = feature as? KMLContainer {
                folder.listContents(indentation: indentation + 1)
            }
        }
    }
}
