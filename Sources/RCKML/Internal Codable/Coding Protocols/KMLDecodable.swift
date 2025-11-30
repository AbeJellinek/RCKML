//
//  KMLDecodable.swift
//  RCKML
//
//  Created by Ryan Linn on 11/18/25.
//

/// A type of `KMLObject` that can be decoded from an XML file through `KMLDecoder`.
protocol KMLDecodable: KMLObject {
    /// Initializes an instance of this type from a `KMLDecoder` element of a KML file.
    ///
    /// - Parameter decoder: A decoder that represents this `KMLObject` in the KML file, and
    ///                      contains sub-elements to be decoded to initialize this instance's
    ///                      properties.
    ///
    /// Implementations of this function should start by verifying the decoder's KML element tag is correctly
    /// matched with this type, and by initializing the object's `id` property:
    ///
    /// ```swift
    /// init(from decoder: KMLDecoder) throws {
    ///     try decoder.verifyMatchesType(Self.self)
    ///     self.id = decoder.idAttribute
    ///     // decode further properties here
    /// }
    /// ```
    ///
    /// Use `KMLDecoder`'s functions to initialize other properties from the KML file object.
    init(from decoder: KMLDecoder) throws
}

/// An enum type conforming to `AnyKML` that can be decoded from an XML file through `KMLDecoder`.
protocol AnyDecodableKML: AnyKML {
    /// Attempts to initialize an instance of this `AnyKML` type from a `KMLDecoder` element.
    ///
    /// - Parameter decoder: A decoder that represents some KML element in the KML file.
    ///
    /// Determine which case of this enum to initialize by comparing the `KMLDecoder` element's
    /// `tagName` to known `KMLObject` types' `kmlTag` properties. If `tagName` doesn't
    /// match any known instances of this `AnyKML` type, throw an `UnsupportedType` error to
    /// indicate the decoder parent should move on from the element.
    ///
    /// See existing implementations for examples, such as `AnyKMLGeometry` or `AnyKMLFeature`.
    init(from decoder: KMLDecoder) throws
}
