//
//  Samples.swift
//  RCKML
//
//  Created by Ryan Linn on 12/6/25.
//

import RCKML

extension KMLCoordinate {
    static var sampleA: KMLCoordinate { KMLCoordinate(latitude: 0, longitude: 0) }
    static var sampleB: KMLCoordinate { KMLCoordinate(latitude: 2, longitude: 0) }
    static var sampleC: KMLCoordinate { KMLCoordinate(latitude: 2, longitude: 1) }
}

extension KMLPoint {
    static var sample: KMLPoint { KMLPoint(coordinate: .sampleA) }
}

extension KMLLineString {
    static var sample: KMLLineString { KMLLineString(coordinates: [.sampleA, .sampleB]) }
}

extension KMLPolygon {
    static var sample: KMLPolygon {
        let ring = try! LinearRing(coordinates: [.sampleA, .sampleB, .sampleC, .sampleA])
        return KMLPolygon(outerBoundary: ring)
    }
}

enum Samples {
    enum Geometries {
        static var pointXml: String {
            "<Point><coordinates>0,0</coordinates></Point>"
        }

        static var lineStringXml: String {
            "<LineString><coordinates>0,0 0,1</coordinates></LineString>"
        }

        static var polygonXml: String {
            "<Polygon><outerBoundaryIs><LinearRing><coordinates>0,0 0,2 1,2 0,0</coordinates></LinearRing></outerBoundaryIs></Polygon>"
        }

        static var multiGeometryXml: String {
            "<MultiGeometry>" + pointXml + lineStringXml + polygonXml + "</MultiGeometry>"
        }
    }
}
