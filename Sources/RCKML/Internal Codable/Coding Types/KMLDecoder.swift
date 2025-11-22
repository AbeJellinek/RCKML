//
//  KMLDecoder.swift
//  RCKML
//
//  Created by Ryan Linn on 11/21/25.
//

import AEXML

/// <#Description#>
struct KMLDecoder {
    private let xml: AEXMLElement

    init(_ xml: AEXMLElement) {
        self.xml = xml
    }

    var idAttribute: String? { xml.attributes["id"] }
    
    /// <#Description#>
    var tagName: String { xml.name }
    
    /// <#Description#>
    /// - Parameter type: <#type description#>
    func verifyMatchesType<K: KMLDecodable>(_ type: K.Type) throws(XMLTagMismatch) {
        if K.kmlTag != tagName {
            throw XMLTagMismatch(expectedTag: K.kmlTag, actualTag: tagName)
        }
    }

    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - key: <#key description#>
    /// - Returns: <#description#>
    func value<K: KMLValue>(of type: K.Type, forKey key: KMLTagName) throws -> K {
        let item = xml[key.name]
        if let error = item.error {
            throw KMLDecoderError.xml(error)
        }
        let typedValue = try K(kmlString: item.string)
        return typedValue
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - key: <#key description#>
    /// - Returns: <#description#>
    func value<R: RawRepresentable>(
        of type: R.Type,
        forKey key: KMLTagName
    ) throws -> R where R.RawValue: KMLValue {
        let rawValue = try value(of: R.RawValue.self, forKey: key)
        guard let value = R(rawValue: rawValue) else {
            throw KMLDecoderError.rawValueDecodeFailed(expected: R.self)
        }
        return value
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - key: <#key description#>
    ///   - `default`: <#`default` description#>
    /// - Returns: <#description#>
    func value<K: KMLValue>(of type: K.Type, forKey key: KMLTagName, `default`: K) -> K {
        if let value = try? value(of: type, forKey: key) {
            return value
        } else {
            return `default`
        }
    }

    /// <#Description#>
    /// - Parameter type: <#type description#>
    /// - Returns: <#description#>
    func child<K: KMLDecodable>(of type: K.Type) throws -> K {
        let child = xml[type.kmlTag]
        if let error = child.error {
            throw error
        }
        let subcontainer = KMLDecoder(child)
        let kmlType = try K(from: subcontainer)
        return kmlType
    }

    /// <#Description#>
    /// - Parameter type: <#type description#>
    /// - Returns: <#description#>
    func children<K: KMLDecodable>(of type: K.Type) -> [K] {
        xml.children
            .filter { $0.name == K.kmlTag }
            .compactMap { try? K(from: KMLDecoder($0)) }
    }
    
    /// <#Description#>
    /// - Parameter type: <#type description#>
    /// - Returns: <#description#>
    func child<K: AnyDecodableKML>(of type: K.Type) throws -> K {
        for aChild in xml.children {
            do {
                let childDeocder = KMLDecoder(aChild)
                let result = try K.init(from: childDeocder)
                return result
            } catch is UnknownKMLType {
                // Unrecognized KML Type, just move on. Otherwise rethrow error.
            }
        }
        // if nothing was found, throw error - not found
        throw KMLDecoderError.childTypeNotFound(expected: String(describing: K.self))
    }
    
    /// <#Description#>
    /// - Parameter type: <#type description#>
    /// - Returns: <#description#>
    func allChildren<K: AnyDecodableKML>(of type: K.Type) throws -> [K] {
        try xml.children
            .map(KMLDecoder.init)
            .compactMap { aDecoder in
                do {
                    return try K.init(from: aDecoder)
                } catch is UnknownKMLType {
                    // if error is unrecognized type, return nil
                    return nil
                }
            }
    }
    
    /// <#Description#>
    /// - Parameter tag: <#tag description#>
    /// - Returns: <#description#>
    func subContainer(withName tag: KMLTagName) throws -> KMLDecoder {
        let nested = xml[tag.name]
        if let error = nested.error {
            throw error
        }
        let container = KMLDecoder(nested)
        return container
    }
}

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
