//
//  KMLEncoder.swift
//  RCKML
//
//  Created by Ryan Linn on 11/21/25.
//

import AEXML

/// A wrapper around an initially empty XML element, used to encode KML elements into a format that can be
/// written to an XML string or file.
///
/// A `KMLEncoder` should never be created directly - instead it is created by calling `encode` functions
/// on a provided `KMLEncoder` in the `KMLEncodable` protocol function `encode(to:)`.
struct KMLEncoder {
    let xml: AEXMLElement

    /// Initializes an encoder with an XML element that has the proper name and id for the given object,
    /// but is otherwise empty.
    ///
    /// For example, the resulting XML from this initializer called using a `KMLPlacemark` would look like
    /// this:
    ///
    /// ```
    /// <Placemark id="myPlacemarkId">
    /// </Placemark>
    /// ```
    ///
    /// All XML tags contained in the placemark need to be added through the encoder's `encode` functions.
    init<K: KMLEncodable>(for object: K) {
        let baseAttributes = ["id" : object.id].compactMapValues(\.self)
        xml = AEXMLElement(name: K.kmlTag, attributes: baseAttributes)
    }

    /// Initializes an encoder with an unchecked XML element. It is up to the caller to ensure that the element
    /// is properly formatted and initialized with necessary properties.
    init(_ xml: AEXMLElement) {
        self.xml = xml
    }
    
    /// Adds a child element with a basic value contained in a named XML element.
    ///
    /// - Parameters:
    ///   - tag: The name of the XML element that will be created.
    ///   - value: The value contained in the XML element.
    ///
    ///
    /// If the `value` parameter is `nil`, no element is added.
    ///
    /// If there is already an element with the given name in the XML element, this function will replace the
    /// existing element.
    ///
    /// Example:
    ///
    /// ```swift
    /// // Before:
    /// // <Placemark>
    /// // </Placemark>
    ///
    /// try encoder.encode(tag: .name, value: "My Placemark")
    ///
    /// // After:
    /// // <Placemark>
    /// // <name>My Placemark</name>
    /// // </Placemark>
    /// ```
    func encode<V: KMLValue>(tag: KMLTagName, value: V?) throws {
        // Remove existing value if already set
        xml[tag.name].removeFromParent()

        guard let value else {
            return
        }
        let element = AEXMLElement(name: tag.name, value: value.kmlString)
        xml.addChild(element)
    }
    
    /// Adds a named child element that can be used to hold sub elements.
    ///
    /// - Parameter tag: The name of the XML element that will be created.
    /// - Returns: An encoder that contains the newly created child element.
    ///
    /// If there is already a child element in this XML element with the same name, this function will replace the
    /// existing element.
    ///
    /// Example:
    ///
    /// ```swift
    /// // Before:
    /// // <Polygon>
    /// // </Polygon>
    ///
    /// let container = try encoder.encodeContainer(tag: .innerBoundaryIs)
    ///
    /// // After:
    /// // <Polygon>
    /// // <InnerBoundaryIs>
    /// // </InnerBoundaryIs>
    /// // </Polygon>
    ///
    /// // XML Element for 'container':
    /// // <InnerBoundaryIs>
    /// // </InnerBoundaryIs>
    /// ```
    func encodeContainer(tag: KMLTagName) throws -> KMLEncoder {
        // Remove existing container if already set
        xml[tag.name].removeFromParent()

        // Add new container element
        let element = AEXMLElement(name: tag.name)
        xml.addChild(element)
        return KMLEncoder(element)
    }

    /// Adds a child element representing any `KMLObject`, which will encode the child using `KMLEncodable`
    /// functions.
    ///
    /// - Parameter object: The child object to add to this encoder.
    ///
    /// If the child is `nil`, no child element will be added.
    ///
    /// If this encoder already contains an element of the same child type, this will add another.
    ///
    /// Example:
    /// ```swift
    /// // Before:
    /// // <Placemark>
    /// // </Placemark>
    ///
    /// try encoder.encodeChild(aPoint)
    ///
    /// // After:
    /// // <Placemark>
    /// // <Point>
    /// // <coordinates>1,2,3</coordinates>
    /// // </Point>
    /// // </Placemark>
    /// ```
    func encodeChild<C: KMLEncodable>(_ object: C?) throws {
        guard let object else {
            return
        }
        try encodeChild(object)
    }
    
    /// Adds a child element representing any case of `AnyEncodableKML`, which will encode the child
    /// using the specific case's `KMLEncodable` functions.
    ///
    /// - Parameter object: The child object to add to this encoder.
    ///
    /// If the child is `nil`, no child element will be added.
    ///
    /// If this encoder already contains an element of the same child type, this will add another.
    ///
    /// Example:
    /// ```swift
    /// // Before:
    /// // <Placemark>
    /// // </Placemark>
    ///
    /// try encoder.encodeChild(AnyKMLGeometry.point(aPoint))
    ///
    /// // After:
    /// // <Placemark>
    /// // <Point>
    /// // <coordinates>1,2,3</coordinates>
    /// // </Point>
    /// // </Placemark>
    /// ```
    func encodeChild<C: AnyEncodableKML>(_ object: C?) throws {
        switch object?.encodable {
        case .object(let objectType):
            try encodeChild(objectType)
        case .value(let name, let value):
            try encode(tag: name, value: value)
        case .none:
            break
        }
    }
}
