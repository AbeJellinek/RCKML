//
//  KMLEncodable.swift
//  RCKML
//
//  Created by Ryan Linn on 11/6/25.
//

import Foundation
import AEXML

protocol KMLEncodable {
    var xmlElement: AEXMLElement { get }
}

@resultBuilder
struct KMLContentBuilder {
    static func buildBlock() -> [any KMLEncodable] {
        []
    }

    static func buildBlock(_ components: [any KMLEncodable]...) -> [any KMLEncodable] {
        components.flatMap { $0 }
    }

    static func buildExpression(_ expression: any KMLEncodable) -> [any KMLEncodable] {
        [expression]
    }

    static func buildExpression(_ expression: (any KMLEncodable)?) -> [any KMLEncodable] {
        expression.map { [$0] } ?? []
    }

    static func buildOptional(_ component: [(any KMLEncodable)]?) -> [any KMLEncodable] {
        component ?? []
    }

    static func buildEither(first: [any KMLEncodable]) -> [any KMLEncodable] {
        first
    }

    static func buildEither(second: [any KMLEncodable]) -> [any KMLEncodable] {
        second
    }

    static func buildArray(_ components: [[any KMLEncodable]]) -> [any KMLEncodable] {
        components.flatMap { $0 }
    }
}
