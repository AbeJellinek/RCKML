//
//  AnyKML.swift
//  RCKML
//
//  Created by Ryan Linn on 11/17/25.
//

public struct UnsupportedType: Error {}

/// An abstract protocol for enums where each case wraps a specific KML element.
///
/// See implementations such as `AnyKMLFeature` or `AnyKMLGeometry` for examples.
public protocol AnyKML {
    associatedtype Wrapped
    
    var wrapped: Wrapped { get }
    
    init(_ wrapped: Wrapped) throws(UnsupportedType)
}
