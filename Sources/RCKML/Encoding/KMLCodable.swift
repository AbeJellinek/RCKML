//
//  KMLEncodable.swift
//  RCKML
//
//  Created by Ryan Linn on 11/6/25.
//

import Foundation
import AEXML

protocol KMLCodable {
    var xmlElement: AEXMLElement { get }
}

protocol KMLCodableObject: KMLCodable, KMLObject {
    /// Initializes the KMLObject using an AEXMLElement read from a KML file.
    /// - Parameter xml: xml element read from a valid KML file.
    init(xml: AEXMLElement) throws

    @KMLContentBuilder var children: [any KMLCodable] { get }
}

// MARK: - Helpers

extension KMLCodableObject {
    var xmlElement: AEXMLElement {
        AEXMLElement(kmlObject: self)
    }

    /// Call this function at the beginning of any `KMLObject.init(xml:)` to
    /// ensure that the xml tag being used to create the object is of the correct
    /// type
    ///
    /// - Parameter xml: the xml element being used to check against.
    /// - Throws: If the xml tag name is different from Self.kmlTag, throws a xmlTagMismatch error.
    static func verifyXmlTag(_ xml: AEXMLElement) throws {
        guard xml.name == kmlTag else {
            throw KMLError.xmlTagMismatch
        }
    }
}

@resultBuilder
struct KMLContentBuilder {
    static func buildBlock() -> [any KMLCodable] {
        []
    }

    static func buildBlock(_ components: [any KMLCodable]...) -> [any KMLCodable] {
        components.flatMap { $0 }
    }

    static func buildExpression(_ expression: any KMLCodable) -> [any KMLCodable] {
        [expression]
    }

    static func buildExpression(_ expression: (any KMLCodable)?) -> [any KMLCodable] {
        expression.map { [$0] } ?? []
    }

    /// This allows for `[any KMLEncodableObject]` to be translated to `[any KMLEncodable]`
    static func buildExpression(_ expression: [any KMLCodable]) -> [any KMLCodable] {
        expression.map { $0 as KMLCodable }
    }

    static func buildOptional(_ component: [(any KMLCodable)]?) -> [any KMLCodable] {
        component ?? []
    }

    static func buildEither(first: [any KMLCodable]) -> [any KMLCodable] {
        first
    }

    static func buildEither(second: [any KMLCodable]) -> [any KMLCodable] {
        second
    }

    static func buildArray(_ components: [[any KMLCodable]]) -> [any KMLCodable] {
        components.flatMap { $0 }
    }
}
