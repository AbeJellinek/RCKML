//
//  KMLMultiGeometryTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/30/25.
//

import AEXML
@testable import RCKML
import Testing

struct KMLMultiGeometryTests {
    @Test func throwingInitializer() throws {
        let _ = try KMLMultiGeometry(geometries: [
            KMLPoint.sample,
            KMLLineString.sample,
            KMLPolygon.sample
        ])
    }

    @Test func decode() throws {
        let decoder = try KMLDecoder(testXml: Samples.Geometries.multiGeometryXml)
        let multiGeom = try decoder.decode(KMLMultiGeometry.self)

        let children = multiGeom.geometries
        let point = children.first(where: { $0.wrapped is KMLPoint })
        #expect(point != nil)

        let lineString = children.first(where: { $0.wrapped is KMLLineString })
        #expect(lineString != nil)

        let polygon = children.first(where: { $0.wrapped is KMLPolygon })
        #expect(polygon != nil)
    }

    @Test func encode() throws {
        let multiGeo = try KMLMultiGeometry(id: "multiples", geometries: [
            KMLPoint.sample,
            KMLLineString.sample,
            KMLPolygon.sample
        ])
        let encoder = try KMLEncoder(wrapping: multiGeo)

        let xmlElement = encoder.xml

        #expect(xmlElement.name == "MultiGeometry")
        #expect(xmlElement.children.count == 3)
        #expect(xmlElement.children(named: "Point").count == 1)
        #expect(xmlElement.children(named: "LineString").count == 1)
        #expect(xmlElement.children(named: "Polygon").count == 1)
    }
}
