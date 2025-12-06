//
//  AnyGeometryTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/29/25.
//

import AEXML
@testable import RCKML
import Testing

struct AnyGeometryTests {
    @Test func initializeAnyGeometries() throws {
        // Point
        let point = KMLPoint(coordinate: .sampleA)
        let anyPoint = try AnyKMLGeometry(point)
        switch anyPoint {
        case .point(let wrapped):
            #expect(wrapped.coordinate == point.coordinate)
        default:
            Issue.record()
        }

        // LineString
        let lineString = KMLLineString(coordinates: [.sampleA, .sampleB])
        let anyLineString = try AnyKMLGeometry(lineString)
        switch anyLineString {
        case .lineString(let wrapped):
            #expect(wrapped.coordinates == lineString.coordinates)
        default:
            Issue.record()
        }

        // Polygon
        let polygonOuter = try KMLPolygon.LinearRing(coordinates: [.sampleA, .sampleB, .sampleC, .sampleA])
        let polygon = KMLPolygon(outerBoundary: polygonOuter)
        let anyPolygon = try AnyKMLGeometry(polygon)
        switch anyPolygon {
        case .polygon(let wrapped):
            #expect(wrapped.outerBoundaryIs.coordinates == polygonOuter.coordinates)
        default:
            Issue.record()
        }

        // MultiGeometry
        let multiGeom = KMLMultiGeometry()
        let anyMulti = try AnyKMLGeometry(multiGeom)
        switch anyMulti {
        case .multiGeometry(_):
            break
        default:
            Issue.record()
        }
    }

    @Test func decodePoint() throws {
        let decoder = try KMLDecoder(testXml: Samples.Geometries.pointXml)
        let anyGeometry = try decoder.decode(AnyKMLGeometry.self)
        switch anyGeometry {
        case .point(_):
            break
        default:
            Issue.record()
        }
    }

    @Test func decodeLineString() throws {
        let decoder = try KMLDecoder(testXml: Samples.Geometries.lineStringXml)
        let anyGeometry = try decoder.decode(AnyKMLGeometry.self)
        switch anyGeometry {
        case .lineString(_):
            break
        default:
            Issue.record()
        }
    }

    @Test func decodePolygon() throws {
        let decoder = try KMLDecoder(testXml: Samples.Geometries.polygonXml)
        let anyGeometry = try decoder.decode(AnyKMLGeometry.self)
        switch anyGeometry {
        case .polygon(_):
            break
        default:
            Issue.record()
        }
    }

    @Test func decodeMultiGeometry() throws {
        let decoder = try KMLDecoder(testXml: Samples.Geometries.multiGeometryXml)
        let anyGeometry = try decoder.decode(AnyKMLGeometry.self)
        switch anyGeometry {
        case .multiGeometry(_):
            break
        default:
            Issue.record()
        }
    }

    @Test func encodePoint() throws {
        let point = KMLPoint(coordinate: .sampleA)
        let anyGeometry = try AnyKMLGeometry(point)
        let encoder = try KMLEncoder(wrapping: anyGeometry)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "Point")
        #expect(xmlElement.children.count == 1)
        #expect(xmlElement["coordinates"].error == nil)
    }

    @Test func encodeLineString() throws {
        let lineString = KMLLineString(coordinates: [.sampleA, .sampleB])
        let anyGeometry = try AnyKMLGeometry(lineString)
        let encoder = try KMLEncoder(wrapping: anyGeometry)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "LineString")
        #expect(xmlElement.children.count == 1)
        #expect(xmlElement["coordinates"].error == nil)
    }

    @Test func encodePolygon() throws {
        let outerBound = try KMLPolygon.LinearRing(coordinates: [.sampleA, .sampleB, .sampleC, .sampleA])
        let polygon = KMLPolygon(outerBoundary: outerBound)
        let anyGeometry = try AnyKMLGeometry(polygon)
        let encoder = try KMLEncoder(wrapping: anyGeometry)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "Polygon")
        #expect(xmlElement.children.count == 1)
        #expect(xmlElement["outerBoundaryIs"].error == nil)
    }

    @Test func encodeMultiGeometry() throws {
        let point1 = KMLPoint(coordinate: .sampleA)
        let point2 = KMLPoint(coordinate: .sampleB)
        let multiGeom = try KMLMultiGeometry(geometries: [point1, point2])
        let anyGeometry = try AnyKMLGeometry(multiGeom)
        let encoder = try KMLEncoder(wrapping: anyGeometry)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "MultiGeometry")
        #expect(xmlElement.children.count == 2)
        #expect(xmlElement.children(named: "Point").count == 2)
    }
}
