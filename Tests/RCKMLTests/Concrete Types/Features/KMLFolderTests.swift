//
//  KMLFolderTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/30/25.
//

import AEXML
@testable import RCKML
import Testing

struct KMLFolderTests {
    // MARK: Decoding

    @Test func decodeWithPlacemarkContent() throws {
        let decoder = try KMLDecoder(testXml: """
            <Folder id="theFolder">
            <name>The Folder</name>
            <description>A sample folder</description>
            <Placemark id="point"><name>Point</name>\(Samples.Geometries.pointXml)</Placemark>
            <Placemark id="line"><name>LineString</name>\(Samples.Geometries.lineStringXml)</Placemark>
            <Placemark id="polygon"><name>Polygon</name>\(Samples.Geometries.polygonXml)</Placemark>
            <Placemark id="multiGeo"><name>MultiGeometry</name>\(Samples.Geometries.multiGeometryXml)</Placemark>
            </Folder>
            """)
        let folder = try decoder.decode(KMLFolder.self)
        #expect(folder.id == "theFolder")
        #expect(folder.name == "The Folder")
        #expect(folder.featureDescription == "A sample folder")

        #expect(folder.features.count == 4)
        let placemarks = folder.features.compactMap { $0.wrapped as? KMLPlacemark }
        #expect(placemarks.count == 4)
        #expect(placemarks.filter({ $0.geometry?.wrapped is KMLPoint }).count == 1)
        #expect(placemarks.filter({ $0.geometry?.wrapped is KMLLineString }).count == 1)
        #expect(placemarks.filter({ $0.geometry?.wrapped is KMLPolygon }).count == 1)
        #expect(placemarks.filter({ $0.geometry?.wrapped is KMLMultiGeometry }).count == 1)
    }

    @Test func decodeWithFolderContent() throws {
        let decoder = try KMLDecoder(testXml: """
            <Folder id="Containing">
            <name>Containing Folder</name>
            <Folder id="Contained">
            <name>Contained Folder</name>
            </Folder>
            </Folder>
            """)
        let containerFolder = try decoder.decode(KMLFolder.self)
        #expect(containerFolder.id == "Containing")
        #expect(containerFolder.features.count == 1)
        let containedFolder = try #require(containerFolder.features.first?.wrapped as? KMLFolder)
        #expect(containedFolder.id == "Contained")
    }

    // MARK: Encoding

    @Test func encodeEmpty() throws {
        let emptyFolder = KMLFolder(
            id: "folderId",
            name: "Folder Name",
            featureDescription: "This is a folder"
        )
        let encoder = try KMLEncoder(wrapping: emptyFolder)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "Folder")
        #expect(xmlElement.attributes["id"] == "folderId")
        #expect(xmlElement["name"].value == "Folder Name")
        #expect(xmlElement["description"].value == "This is a folder")
    }

    @Test func encodeWithContents() throws {
        let placemark1 = KMLPlacemark(name: "Point1", geometry: .point(.sample))
        let placemark2 = KMLPlacemark(name: "Point2", geometry: .point(.sample))
        let subFolder = KMLFolder(id: "subFolder")

        let folder = try KMLFolder(features: [
            placemark1,
            placemark2,
            subFolder
        ])
        let encoder = try KMLEncoder(wrapping: folder)

        let xmlElement = encoder.xml
        let placemarkContents = xmlElement.children(named: "Placemark")
        #expect(placemarkContents.count == 2)
        let subFolderContents = xmlElement.children(named: "Folder")
        #expect(subFolderContents.count == 1)
    }
}
