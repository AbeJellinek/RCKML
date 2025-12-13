//
//  AnyFeatureTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/29/25.
//

import AEXML
@testable import RCKML
import Testing

struct AnyFeatureTests {
    @Test func initializeAnyFeature() throws {
        // Folder
        let folder = KMLFolder(id: "folder")
        let anyFolder = try AnyKMLFeature(folder)
        switch anyFolder {
        case .folder(let wrapped):
            #expect(wrapped.id == "folder")
        default:
            Issue.record()
        }

        // Placemark
        let placemark = KMLPlacemark(
            id: "placemark",
            name: nil,
            geometry: .point(.sample)
        )
        let anyPlacemark = try AnyKMLFeature(placemark)
        switch anyPlacemark {
        case .placemark(let wrapped):
            #expect(wrapped.id == "placemark")
        default:
            Issue.record()
        }

        // Document
        let document = KMLDocument(id: "document")
        let anyDocument = try AnyKMLFeature(document)
        switch anyDocument {
        case .document(let wrapped):
            #expect(wrapped.id == "document")
        default:
            Issue.record()
        }
    }

    @Test func decodeFolder() throws {
        let decoder = try KMLDecoder(testXml: """
            <Folder id="folder">
            </Folder>
            """)
        let anyFeature = try decoder.decode(AnyKMLFeature.self)
        switch anyFeature {
        case .folder(_):
            break
        default:
            Issue.record()
        }
    }

    @Test func decodePlacemark() throws {
        let decoder = try KMLDecoder(testXml: """
            <Placemark>
            <Point><coordinates>0,0</coordinates></Point>
            </Placemark>
            """)
        let anyFeature = try decoder.decode(AnyKMLFeature.self)
        switch anyFeature {
        case .placemark(_):
            break
        default:
            Issue.record()
        }
    }

    @Test func decodeDocument() throws {
        let decoder = try KMLDecoder(testXml: """
            <Document></Document>
            """)
        let anyFeature = try decoder.decode(AnyKMLFeature.self)
        switch anyFeature {
        case .document(_):
            break
        default:
            Issue.record()
        }
    }

    @Test func encodeFolder() throws {
        let folder = KMLFolder(id: "folder", name: "My Folder")
        let anyFeature = try AnyKMLFeature(folder)
        let encoder = try KMLEncoder(wrapping: anyFeature)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "Folder")
        #expect(xmlElement.attributes["id"] == "folder")
    }

    @Test func encodePlacemark() throws {
        let placemark = KMLPlacemark(
            id: "placemark",
            name: nil,
            geometry: .point(.sample)
        )
        let anyFeature = try AnyKMLFeature(placemark)
        let encoder = try KMLEncoder(wrapping: anyFeature)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "Placemark")
        #expect(xmlElement.attributes["id"] == "placemark")
    }

    @Test func encodeDocument() throws {
        let document = KMLDocument(id: "sampleDocument")
        let anyFeature = try AnyKMLFeature(document)
        let encoder = try KMLEncoder(wrapping: anyFeature)

        let xmlElement = encoder.xml
        #expect(xmlElement.name == "Document")
        #expect(xmlElement.attributes["id"] == "sampleDocument")
    }
}
