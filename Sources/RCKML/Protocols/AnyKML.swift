//
//  AnyKML.swift
//  RCKML
//
//  Created by Ryan Linn on 11/17/25.
//

public struct UnsupportedType: Error {}

/// A protocol adopted by type-erasing wrappers around KML element groups (features, geometries, styles, etc)
/// to allow storage and access to heterogenous collections of related KML types.
///
/// `AnyKML` types are typically enums where each case holds an associated value of a different type. For
/// instance, `AnyKMLFeature`'s wrapped type is the protocol `KMLFeature`, and its cases are
/// `placemark`, `folder`, and `document`. Therefore, an `AnyKMLFeature` instance can be used
/// to read the exact type of feature and use it with the knowledge that it is safely only one of the existing
/// KML feature types supported by the KML language.
///
/// See implementations such as `AnyKMLFeature` or `AnyKMLGeometry` for complete examples.
public protocol AnyKML {
    associatedtype Wrapped

    /// Returns the wrapped value of the `AnyKML` instance as an alternative for accessing the wrapped
    /// value directly rather than using switch or case-let semantics.
    var wrapped: Wrapped { get }

    /// Creates an instance of the `AnyKML` type from its wrapped type.
    ///
    /// - Throws: `UnsupportedType` error if the `AnyKML` type can't represent the wrapped type.
    init(_ wrapped: Wrapped) throws(UnsupportedType)
}
