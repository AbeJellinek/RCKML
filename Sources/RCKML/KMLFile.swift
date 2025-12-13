//
//  KMLFile.swift
//  RCKML
//
//  Created by Ryan Linn on 12/12/25.
//

import AEXML
import Foundation
import ZIPFoundation

public enum KMLFileError: Error {
    case failedStringConversion
    case kmzReadFailure
    case kmzUnzipFailure
    case kmzWriteFailure
    case missingKmlRoot
    case unknownFileExtension(String)
}

public struct KMLFile {
    public var features: [AnyKMLFeature]

    public init(features: [AnyKMLFeature]? = nil) {
        self.features = features ?? []
    }

    public init(features: [any KMLFeature]) throws {
        self.features = try features.map(AnyKMLFeature.init)
    }

    public init(_ data: Data) throws {
        let xmlDoc = try AEXMLDocument(xml: data)
        let kmlElement = xmlDoc["kml"]
        guard kmlElement.error == nil else {
            throw KMLFileError.missingKmlRoot
        }

        let decoder = KMLDecoder(kmlElement)
        self.features = try decoder.decode([AnyKMLFeature].self)
    }

    public init(kmzData: Data) throws {
        let archive = try Archive(data: kmzData, accessMode: .read, pathEncoding: .utf8)

        guard let kmlEntry = archive.first(where: { $0.path.hasSuffix("kml") }) else {
            throw KMLFileError.kmzReadFailure
        }

        var extractedData = Data()
        let _ = try? archive.extract(kmlEntry, consumer: { extractedData += $0 })
        guard  !extractedData.isEmpty else {
            throw KMLFileError.kmzUnzipFailure
        }

        try self.init(extractedData)
    }

    public init(_ kmlString: String) throws {
        guard let data = kmlString.data(using: .utf8) else {
            throw KMLFileError.failedStringConversion
        }
        try self.init(data)
    }

    /// Initializes a KMLDocument from a fileUrl, which must have a path extension of either "KML" or
    /// "KMZ" (neither are case-sensitive).
    public init(_ url: URL) throws {
        let data = try Data(contentsOf: url)
        switch url.pathExtension.lowercased() {
        case "kml":
            try self.init(data)
        case "kmz":
            try self.init(kmzData: data)
        default:
            throw KMLFileError.unknownFileExtension(url.pathExtension)
        }
    }


    /// Returns the full string representation of the KML file.
    public func kmlString() throws -> String {
        let xmlDoc = AEXMLDocument()
        let baseAttributes = ["xmlns" : "http://www.opengis.net/kml/2.2"]
        let kmlRoot = xmlDoc.addChild(name: "kml", attributes: baseAttributes)

        let encoder = KMLEncoder(kmlRoot)
        for feature in features {
            try encoder.encodeChild(feature)
        }

        return xmlDoc.xml
    }

    /// Returns the file data representation of the KML file.
    public func kmlData() throws -> Data {
        guard let result = try kmlString().data(using: .utf8) else {
            throw KMLFileError.failedStringConversion
        }
        return result
    }

    /// Returns the file data representation as a KMZ file.
    public func kmzData() throws -> Data {
        let archive = try Archive(data: Data(), accessMode: .create, pathEncoding: .utf8)

        let normalData = try kmlData()
        try archive.addEntry(
            with: "doc.kml",
            type: .file,
            uncompressedSize: Int64(normalData.count),
            compressionMethod: .deflate,
            provider: { position, size in
                let startIndex = Data.Index(position)
                let endIndex = Data.Index(position + Int64(size))
                return normalData.subdata(in: startIndex..<endIndex)
            })

        guard let result = archive.data else {
            throw KMLFileError.kmzWriteFailure
        }
        return result
    }
}
