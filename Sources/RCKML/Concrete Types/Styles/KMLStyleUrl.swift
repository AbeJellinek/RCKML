//
//  KMLStyleUrl.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import AEXML
import Foundation

/// A wrapper around a KMLStyleSelector's id, used for referencing that
/// style from another style.
///
/// For more info, see [KML Spec](https://developers.google.com/kml/documentation/kmlreference#styleurl)
public struct KMLStyleUrl: Hashable {
    public var styleId: String

    public init(styleId: String) {
        self.styleId = styleId
    }
}

// MARK: - KML Codable

extension KMLStyleUrl: KMLValue {
    var kmlString: String {
        "#" + styleId
    }

    init(kmlString: String) throws {
        self.styleId = kmlString
        if styleId.first == "#" {
            styleId.removeFirst()
        }
    }
}
