//
//  KMLValue.swift
//  RCKML
//
//  Created by Ryan Linn on 11/6/25.
//

import Foundation

/// A type that can be read from or written to a KML file as a simple property of a `KMLObject`.
///
/// Any value type can be a `KMLValue` as long as it can be read from a String or written to a String, with
/// no children.
///
/// For example, in the following KML string, "My Name" and "0" are both `KMLValue`s, one of type `String`,
/// and the other of type `Bool` (although it could also be `Int`).
///
/// ```
/// <Placemark>
///    <name>My Name</name>
///    <open>0</open>
/// </Placemark>
/// ```
protocol KMLValue {
    var kmlString: String { get }
    init(kmlString: String) throws
}

struct KMLValueDecodeError<V: KMLValue>: Error {
    var value: String

    init(type: V.Type, value: String) {
        self.value = value
    }
}

extension String: KMLValue {
    var kmlString: String { self }

    init(kmlString: String) throws {
        self = kmlString
    }
}

extension Int: KMLValue {
    var kmlString: String { "\(self)" }

    init(kmlString: String) throws {
        if let intVal = Int(kmlString) {
            self = intVal
        } else {
            throw KMLValueDecodeError(type: Self.self, value: kmlString)
        }
    }
}

extension Double: KMLValue {
    var kmlString: String { "\(self)" }

    init(kmlString: String) throws {
        if let doubleVal = Double(kmlString) {
            self = doubleVal
        } else {
            throw KMLValueDecodeError(type: Self.self, value: kmlString)
        }
    }
}

extension Bool: KMLValue {
    var kmlString: String { self ? "1" : "0" }

    init(kmlString: String) throws {
        if let boolVal = Bool(kmlString) {
            self = boolVal
        } else {
            throw KMLValueDecodeError(type: Self.self, value: kmlString)
        }
    }
}

