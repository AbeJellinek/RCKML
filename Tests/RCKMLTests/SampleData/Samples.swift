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

extension KMLPlacemark {
    static func sampleWithPoint(
        id: String = "pointSample",
        name: String = "Point Sample"
    ) -> KMLPlacemark {
        KMLPlacemark(id: id, name: name, geometry: .point(.sample))
    }

    static func sampleWithLineString(
        id: String = "lineStringSample",
        name: String = "lineStringSample"
    ) -> KMLPlacemark {
        KMLPlacemark(id: id, name: name, geometry: .lineString(.sample))
    }

    static func sampleWithPolygon(
        id: String = "polygonSample",
        name: String = "Polygon Sample"
    ) -> KMLPlacemark {
        KMLPlacemark(id: id, name: name, geometry: .polygon(.sample))
    }
}

extension KMLStyle {
    static func sampleRedLine(id: String = "sampleLineStyle", width: Double = 4.0) -> KMLStyle {
        KMLStyle(
            id: id,
            lineStyle: KMLLineStyle(width: width, color: .init(red: 1.0, green: 0.0, blue: 0.0)),
            polyStyle: nil
        )
    }

    static func sampleBlueFilledPolygon(id: String = "samplePolygonStyle") -> KMLStyle {
        KMLStyle(
            id: id,
            polyStyle: KMLPolyStyle(
                isFilled: true,
                isOutlined: true,
                color: .init(red: 0, green: 0, blue: 1)
            )
        )
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

    enum Styles {
        static var styleMapWithUrlsXml: String {
            """
            <StyleMap id="urlExample">
            <Pair>
            <key>normal</key>
            <styleUrl>#normalStyle</styleUrl>
            </Pair>
            <Pair>
            <key>highlight</key>
            <styleUrl>#highlightStyle</styleUrl>
            </Pair>
            </StyleMap>
            """
        }

        static var styleMapWithStylesXml: String {
            """
            <StyleMap id="styleExample">
            <Pair>
            <key>normal</key>
            <Style id="normalStyle"></Style>
            </Pair>
            <Pair>
            <key>highlight</key>
            <Style id="highlightStyle"></Style>
            </Pair>
            </StyleMap>
            """
        }
    }

    enum Document {
        static var sampleXml: String {
            """
            <Document id="sampleDocument">
            <name>Sample Document</name>
            <description>A sample document</description>
            \(Styles.styleMapWithUrlsXml)
            \(Styles.styleMapWithStylesXml)
            <Placemark id="lineStringPlacemark">\(Geometries.lineStringXml)</Placemark>
            <Placemark id="pointPlacemark">\(Geometries.pointXml)</Placemark>
            <Placemark id="polygonPlacemark">\(Geometries.polygonXml)</Placemark>
            <Folder id="sampleFolder"><name>Sample Folder</name></Folder>
            </Document>
            """
        }
    }
}
