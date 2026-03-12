//
//  KMLDecoder.swift
//  RCKML
//
//  Created by Ryan Linn on 11/21/25.
//

import AEXML

// MARK: - Error Types

struct XMLTagMismatch: Error {
    var expectedTag: String
    var actualTag: String
}

enum KMLDecoderError: Error {
    case xml(AEXMLError)
    case rawValueDecodeFailed(expected: Any.Type)
    case childTypeNotFound(expected: String)
}

// MARK: - Decoder

/// A wrapper around an XML element, used to decode KML elements from a string or file.
///
/// A `KMLDecoder` should never be created directly. It is provided to types conforming to
/// `KMLDecodable` in the `init(from:)` function, and should be used to read the KML object's
/// properties from the XML element.
struct KMLDecoder {
    private let xml: AEXMLElement

    init(_ xml: AEXMLElement) {
        self.xml = xml
    }

    var idAttribute: String? { xml.attributes["id"] }
    
    /// Returns the name of the wrapped XML element.
    ///
    /// For example, if the wrapped XML element is:
    ///
    /// ```
    /// <Container><Placemark></Placemark><Folder></Folder></Container>
    /// ```
    ///
    /// The `tagName` of the element is `Container`. Child elements have the name `Placemark`
    /// and `Folder`.
    var tagName: String { xml.name }
    
    /// Compares the `tagName` property of the decoder to the `kmlTag` property of the
    /// `KMLDecodable` type provided.
    ///
    /// - Parameter type: The expected `KMLDecodable` type to be initialized. This should
    /// generally be called as `Self.self`, in order to prepare the `init(from:)` initializer.
    ///
    /// - Throws: `XMLTagMismatch` if the tag doesn't match the expected type.
    func verifyMatchesType<K: KMLDecodable>(_ type: K.Type) throws(XMLTagMismatch) {
        if K.kmlTag != tagName {
            throw XMLTagMismatch(expectedTag: K.kmlTag, actualTag: tagName)
        }
    }

    /// Decodes a basic value from the decoder.
    ///
    /// - Parameters:
    ///   - type: The expected type to return.
    ///   - key: The XML tag name containing the decodable value.
    ///
    /// - Returns: The decoded value.
    ///
    /// - Throws: Either a `KMLDecoderError` if an XML element with the given tag name can't be
    /// found, or another error type if an XML element exists but could not be converted to the expected
    /// `KMLValue` type.
    ///
    /// If multiple children have the same tag name, the decoder will only attempt to decode the first
    /// available.
    ///
    /// Example:
    ///
    /// ```swift
    /// // KMLDecoder wrapping the following element:
    /// // <Placemark><name>My Location</name></Placemark>
    ///
    /// let placeName = try decoder.decode(String.self, forKey: .name)
    /// // placeName == "My Location"
    /// ```
    func decode<K: KMLValue>(_ type: K.Type, forKey key: KMLTagName) throws -> K {
        let item = xml[key.name]
        if let error = item.error {
            throw KMLDecoderError.xml(error)
        }
        let typedValue = try K(kmlString: item.string)
        return typedValue
    }
    
    /// Attempts to cast the decoder to a given basic value type.
    ///
    /// - Parameters:
    ///   - type: They expected type to return.
    ///   - key: An optional XML tag name that the decoder must match if given.
    ///
    /// - Returns: The decoded value.
    ///
    /// - Throws: Either `XMLTagMismatch` if there was a given key value that doesn't match the
    /// decoder's tag name, or an error from attempting to initialize the `KMLValue` type with the decoder's
    /// string value.
    ///
    /// Example:
    ///
    /// ```swift
    /// // KMLDecoder wrapping the following element:
    /// // <name>Item Name</name>
    ///
    /// let name = try decoder.as(String.self, forKey: .name)
    /// // name == "Item Name"
    ///
    /// let anyString = try decoder.as(String.self)
    /// // anyString == "Item Name"
    ///
    /// let failed = try decoder.as(String.self, forKey: .color)
    /// // throws XMLTagMismatch error because `color` does not match `<name>`
    /// ```
    func `as`<K: KMLValue>(_ type: K.Type, forKey key: KMLTagName? = nil) throws -> K {
        if let key,
           xml.name != key.name
        {
            throw XMLTagMismatch(expectedTag: key.name, actualTag: xml.name)
        }
        return try K(kmlString: xml.string)
    }

    /// Decodes a basic value from the decoder, using a `RawRepresentable` value that can be converted
    /// to `KMLValue`.
    ///
    /// - Parameters:
    ///   - type: The expected type to return.
    ///   - key: The XML tag name containing the decodable value.
    ///
    /// - Returns: The decoded value.
    ///
    /// - Throws: Either a `KMLDecoderError` if an XML element with the given tag name can't be
    /// found, or another error type if an XML element exists but could not be converted to the expected
    /// `KMLValue` type.
    ///
    /// If multiple children have the same tag name, the decoder will only attempt to decode the first
    /// available.
    ///
    /// Example:
    ///
    /// ```swift
    /// // KMLDecoder wrapping the following element:
    /// // <Placemark><name>My Location</name></Placemark>
    ///
    /// let placeName = try decoder.decode(String.self, forKey: .name)
    /// // placeName == "My Location"
    /// ```
    func decode<R: RawRepresentable>(
        _ type: R.Type,
        forKey key: KMLTagName
    ) throws -> R where R.RawValue: KMLValue {
        let rawValue = try decode(R.RawValue.self, forKey: key)
        guard let value = R(rawValue: rawValue) else {
            throw KMLDecoderError.rawValueDecodeFailed(expected: R.self)
        }
        return value
    }

    /// Attempts to cast the decoder to a given basic value type.
    ///
    /// - Parameters:
    ///   - type: They expected type to return.
    ///   - key: An optional XML tag name that the decoder must match if given.
    ///
    /// - Returns: The decoded value.
    ///
    /// - Throws: Either `XMLTagMismatch` if there was a given key value that doesn't match the
    /// decoder's tag name, or an error from attempting to initialize the `KMLValue` type with the decoder's
    /// string value.
    ///
    /// Example:
    ///
    /// ```swift
    /// // KMLDecoder wrapping the following element:
    /// // <name>Item Name</name>
    ///
    /// let name = try decoder.as(String.self, forKey: .name)
    /// // name == "Item Name"
    ///
    /// let anyString = try decoder.as(String.self)
    /// // anyString == "Item Name"
    ///
    /// let failed = try decoder.as(String.self, forKey: .color)
    /// // throws XMLTagMismatch error because `color` does not match `<name>`
    /// ```
    func `as`<R: RawRepresentable>(
        _ type: R.Type,
        forKey key: KMLTagName? = nil
    ) throws -> R where R.RawValue: KMLValue {
        let rawValue = try self.as(R.RawValue.self, forKey: key)
        guard let value = R(rawValue: rawValue) else {
            throw KMLDecoderError.rawValueDecodeFailed(expected: R.self)
        }
        return value
    }

    /// Decodes a basic value from the decoder, optionally returning a default value if the decoder fails..
    ///
    /// - Parameters:
    ///   - type: The expected type to return.
    ///   - key: The XML tag name containing the decodable value.
    ///   - default:The value to return if the decoder can't find or decode an XML element.
    ///
    /// - Returns: The decoded value, or the default value..
    ///
    /// If multiple children have the same tag name, the decoder will only attempt to decode the first
    /// available.
    ///
    /// Example:
    ///
    /// ```swift
    /// // KMLDecoder wrapping the following empty element:
    /// // <Placemark></Placemark>
    ///
    /// let placeName = try decoder.decode(String.self, forKey: .name, default: "No Name")
    /// // placeName == "No Name"
    /// ```
    func decode<K: KMLValue>(
        _ type: K.Type,
        forKey key: KMLTagName,
        `default`: K
    ) -> K {
        if let value = try? decode(type, forKey: key) {
            return value
        } else {
            return `default`
        }
    }

    /// Decodes a child object of the given type from the decoder.
    ///
    /// - Parameter type: The expected `KMLDecodable` type to decode.
    ///
    /// - Returns: The first XML child element matching the output type's `kmlTag` property, decoded
    /// into that output type.
    ///
    /// - Throws: If no child matching the output type's `kmlTag` property is found, or if the first matching
    /// child element fails to decode into the matching output type.
    ///
    /// If multiple children of the child type exist, the decoder will only attempt to decode the first available.
    ///
    /// Example:
    ///
    /// ```swift
    /// // KMLDecoder wrapping the following element:
    /// // <Placemark><Point><coordinates>1,2,3</coordinates></Point></Placemark>
    ///
    /// let pointGeometry = try decoder.decode(Point.self)
    /// // pointGeometry is an instance of KMLPoint
    /// ```
    func decode<K: KMLDecodable>(_ type: K.Type) throws -> K {
        let child = xml[type.kmlTag]
        if let error = child.error {
            throw error
        }
        let subcontainer = KMLDecoder(child)
        let kmlType = try K(from: subcontainer)
        return kmlType
    }

    /// Decodes all child objects of the given type from the decoder.
    ///
    /// - Parameter type: The expected `KMLDecodable` type to decode.
    ///
    /// - Returns: All XML child elements matching the output type's `kmlTag` property, decoded
    /// into that output type. If no children of the matching type exist, the return value is an empty array.
    ///
    /// - Throws: If any of the child elements fail to decode.
    ///
    /// Example:
    ///
    /// ```swift
    /// // KMLDecoder wrapping the following element:
    /// // <Placemark><Point><coordinates>1,2,3</coordinates></Point></Placemark>
    ///
    /// let points = try decoder.decode([Point].self)
    /// // points is an array with a single instance of KMLPoint
    /// ```
    func decode<K: KMLDecodable>(_ type: [K].Type) throws -> [K] {
        try xml.children
            .filter { $0.name == K.kmlTag }
            .map { try K(from: KMLDecoder($0)) }
    }
    
    /// Decodes the first child object of the given type from the decoder.
    ///
    /// - Parameter type: The expected `AnyDecodableKML` type to decode.
    ///
    /// - Returns: The first XML child element that can be decoded into the given `AnyDecodableKML`
    /// type, if any.
    ///
    /// - Throws: If no child element can be found that can be decoded into the `AnyDecodableKML`
    /// type, or if any of the attempted elements fail to decode.
    ///
    /// If multiple children of the child type exist, the decoder will only attempt to decode the first available.
    ///
    /// Example:
    ///
    /// ```swift
    /// // KMLDecoder wrapping the following element:
    /// // <Placemark><Point><coordinates>1,2,3</coordinates></Point></Placemark>
    ///
    /// let anyGeometry = try decoder.decode(AnyKMLGeometry.self)
    /// // pointGeometry is AnyKMLGeometry.point(point)
    /// ```
    func decode<K: AnyDecodableKML>(_ type: K.Type) throws -> K {
        for aChild in xml.children {
            do {
                let childDeocder = KMLDecoder(aChild)
                let result = try K.init(from: childDeocder)
                return result
            } catch is UnsupportedType {
                // Unrecognized KML Type, just move on. Otherwise rethrow error.
            }
        }
        // if nothing was found, throw error - not found
        throw KMLDecoderError.childTypeNotFound(expected: String(describing: K.self))
    }
    
    /// Decodes all child objects of the given type from the decoder.
    ///
    /// - Parameter type: The expected `AnyDecodableKML` type to decode.
    ///
    /// - Returns: All XML child elements that can  be decoded into the given `AnyDecodableKML`
    /// type. If no children of the matching type exist, the return value is an empty array.
    ///
    /// - Throws: If any of the child elements fail to decode.
    ///
    /// Example:
    ///
    /// ```swift
    /// // KMLDecoder wrapping the following element:
    /// // <Placemark><Point><coordinates>1,2,3</coordinates></Point></Placemark>
    ///
    /// let geometries = try decoder.decode([AnyKMLGeometry].self)
    /// // geometries is an array with a single instance of AnyKMLGeometry.point(point)
    /// ```
    func decode<K: AnyDecodableKML>(_ type: [K].Type) throws -> [K] {
        try xml.children
            .map(KMLDecoder.init)
            .compactMap { aDecoder in
                do {
                    return try K.init(from: aDecoder)
                } catch is UnsupportedType {
                    // if error is unrecognized type, return nil
                    return nil
                }
            }
    }
    
    /// Attempts to decode all untyped child elements of the decoder matching the given name.
    ///
    /// - Parameter tag: The name of the expected child element
    ///
    /// - Returns: An array of untyped `KMLDecoder`s wrapping the child element.
    ///
    /// Use this function only for elements that should contain other sub-elements, but have no other KML
    /// type requirements. For example, given the following element:
    ///
    /// ```
    /// <Polygon>
    /// <innerBoundaryIs>
    /// <LinearRing></LinearRing>
    /// </innerBoundaryIs>
    /// <innerBoundaryIs>
    /// <LinearRing></LinearRing>
    /// <innerBoundaryIs>
    /// </Polygon>
    /// ```
    ///
    /// Use `decodeUntyped(named:)` to access the `innerBoundaryIs` elements, which can
    /// then be used to access children of type `LinearRing`.
    func decodeUntyped(named tag: KMLTagName) -> [KMLDecoder] {
        xml.children
            .filter { $0.name == tag.name }
            .map { KMLDecoder($0) }
    }

    /// Decodes all child elements with the given tag name as string values.
    ///
    /// Unlike `decode(_:forKey:)` which returns only the first match, this returns
    /// all children matching the tag name. Useful for elements like `gx:Track` where
    /// multiple `<when>` or `<gx:coord>` children appear.
    func decodeAll(forKey key: KMLTagName) -> [String] {
        xml.children
            .filter { $0.name == key.name }
            .map(\.string)
    }
}
