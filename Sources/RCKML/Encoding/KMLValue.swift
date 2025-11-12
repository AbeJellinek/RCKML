//
//  KMLValue.swift
//  RCKML
//
//  Created by Ryan Linn on 11/6/25.
//

import Foundation

/// <#Description#>
protocol KMLValue {
    var kmlString: String { get }
    init(kmlString: String) throws
}

struct KMLValueDecodeError<V: KMLValue>: LocalizedError {
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

