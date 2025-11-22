//
//  SomeKML.swift
//  RCKML
//
//  Created by Ryan Linn on 11/17/25.
//

public struct UnknownKMLType: Error {}

public protocol SomeKML {
    associatedtype Wrapped

    var wrapped: Wrapped { get }

    init(_ wrapped: Wrapped) throws(UnknownKMLType)
}
