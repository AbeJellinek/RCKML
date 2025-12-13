//
//  KMLFileTests.swift
//  RCKML
//
//  Created by Ryan Linn on 12/13/25.
//

import Foundation
import RCKML
import Testing

struct KMLFileTests {
    @Test func readFromFile() throws {
        let url = try KMLFile.sampleFileUrl
        let decodedFile = try KMLFile(url)

        #expect(decodedFile.features.count == 1)
        let _ = try #require(decodedFile.features.first?.wrapped as? KMLDocument)
    }

    @Test func writeData() throws {
        let file = try KMLFile(features: [
            KMLDocument(name: "Sample Document")
        ])
        let uncompressedFileData = try file.kmlData()
        let compressedFileData = try file.kmzData()

        let decodedUncompressed = try KMLFile(uncompressedFileData)
        let decodedCompressed = try KMLFile(kmzData: compressedFileData)

        let uncompressedDoc = try #require(decodedUncompressed.features.first?.wrapped as? KMLDocument)
        let compressedDoc = try #require(decodedCompressed.features.first?.wrapped as? KMLDocument)
        #expect(uncompressedDoc.name == "Sample Document")
        #expect(compressedDoc.name == "Sample Document")
    }
}
