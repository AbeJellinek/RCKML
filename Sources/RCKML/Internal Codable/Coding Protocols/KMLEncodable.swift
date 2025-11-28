//
//  KMLEncodable.swift
//  RCKML
//
//  Created by Ryan Linn on 11/18/25.
//

/// A type of `KMLObject` that can be encoded to an XML file through `KMLEncoder`.
protocol KMLEncodable: KMLObject {
    /// Writes the value of this `KMLObject` into a `KMLEncoder` for storage to a KML file.
    ///
    /// - Parameter encoder: An encoder that represents this `KMLObject`'s KML element, and is
    ///                      used to encode values or child elements of the object.
    ///
    /// Implementations of this function can ignore the object's `id` attribute, since that is encoded upon
    /// initialization of the `KMLEncoder`. All other properties of the object should be encoded through the
    /// encoder's various `encode` functions.
    func encode(to encoder: KMLEncoder) throws
}

/// A type used to generate either `KMLEncodable` or `KMLValue` for encoding instances of
/// `AnyEncodableKML` to `KMLEncoder`.
enum EncodingValueType {
    /// Used to generate a child object for the current `KMLEncoder` element.
    case object(any KMLEncodable)
    /// Used to add a `KMLValue` tag into the current `KMLEncoder` element.
    case value(name: KMLTagName, value: any KMLValue)
}

/// An enum type conforming to `AnyKML` that can be encoded to an XML file through `KMLEncoder` by
/// generating either a specific `KMLEncodable` or `KMLValue` type to encode.
protocol AnyEncodableKML: AnyKML {
    /// Each instance of `AnyEncodableKML` must be able to create an instance of `EncodableValueType`
    /// to reference itself for encoding into a `KMLEncoder` element.
    ///
    /// If the instance of `AnyEncodableKML` should be added as a child object, return `object(_:)`,
    /// and if the instance should be added as a value property to the KML element, return
    /// `value(name:value:)`.
    var encodable: EncodingValueType { get }
}

