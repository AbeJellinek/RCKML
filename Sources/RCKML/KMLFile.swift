//
//  KMLFile.swift
//  RCKML
//
//  Created by Ryan Linn on 12/12/25.
//

import AEXML
import Foundation
import ZIPFoundation

/// Errors that can occur when reading or writing KML/KMZ data via `KMLFile`.
public enum KMLFileError: Error {
    case failedStringConversion
    case kmzReadFailure
    case kmzUnzipFailure
    case kmzWriteFailure
    case missingKmlRoot
    case unknownFileExtension(String)
}

/// A wrapper for reading and writing KML/KMZ files.
///
/// `KMLFile` represents the file-level container for KML data. It can contain one or more `KMLFeature`
/// objects (typically a single `KMLDocument`) wrapped in `AnyKMLFeature` enum. Use `KMLFile`
/// for reading and writing KML data to and from file.
///
/// To write KML files, construct your `KMLFile` using either of the `init(features:)` initializers, and
/// then create `Data` with either `kmlData()` or `kmzData()` functions.
///
/// To read KML files, initialize the `KMLFile` with initializers that take either `Data`, `String`, or `URL`,
/// and then read the contained data by iterating the `features` property.
public struct KMLFile {
    public var features: [AnyKMLFeature]

    /// Whether any feature in the file uses Google Earth `gx:` extensions.
    private var usesGxExtensions: Bool {
        features.contains(where: Self.featureUsesGx)
    }

    private static func featureUsesGx(_ feature: AnyKMLFeature) -> Bool {
        switch feature {
        case .placemark(let pm):
            guard let geometry = pm.geometry else { return false }
            return geometryUsesGx(geometry)
        case .folder(let folder):
            return folder.features.contains(where: featureUsesGx)
        case .document(let doc):
            return doc.features.contains(where: featureUsesGx)
        }
    }

    private static func geometryUsesGx(_ geometry: AnyKMLGeometry) -> Bool {
        switch geometry {
        case .track:
            return true
        case .multiGeometry(let mg):
            return mg.geometries.contains(where: geometryUsesGx)
        case .lineString, .polygon, .point:
            return false
        }
    }

    public init(features: [AnyKMLFeature]? = nil) {
        self.features = features ?? []
    }

    public init(features: [any KMLFeature]) throws {
        self.features = try features.map(AnyKMLFeature.init)
    }
    
    /// Initializes `KMLFile` from raw XML file data.
    ///
    /// - Parameter data: The raw XML file data to parse.
    ///
    /// - Throws: If XML could not be parsed from the file data, or if any `KMLFeature` failed to decode.
    public init(_ data: Data) throws {
        let xmlDoc = try AEXMLDocument(xml: data)
        let kmlElement = xmlDoc["kml"]
        guard kmlElement.error == nil else {
            throw KMLFileError.missingKmlRoot
        }

        let decoder = KMLDecoder(kmlElement)
        self.features = try decoder.decode([AnyKMLFeature].self)
    }
    
    /// Initializes `KMLFile` from data in a KMZ file.
    ///
    /// - Parameter kmzData: The raw data of the KMZ file.
    ///
    /// - Throws: If the KMZ file is missing its internal KML file, if the KML file could not be parsed into
    /// XML, or if any `KMLFeature` in the file failed to decode.
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
    
    /// Initializes `KMLFile` from a raw XML string.
    ///
    /// - Parameter kmlString: The raw XML string to parse.
    ///
    /// - Throws: If the XML string could not be parsed, or if any `KMLFeature` failed to decode.
    public init(_ kmlString: String) throws {
        guard let data = kmlString.data(using: .utf8) else {
            throw KMLFileError.failedStringConversion
        }
        try self.init(data)
    }

    /// Initializes `KMLFile` from a file at the given URL.
    ///
    /// - Parameter url: The url of the file to read
    ///
    /// - Throws: If the file is not of a recognized format (KML or KMZ), or if the decoder fails to parse
    /// the XML contents of the file, or if any `KMLFeature` in the file fails to decode.
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
        var attributes = ["xmlns" : "http://www.opengis.net/kml/2.2"]
        if usesGxExtensions {
            attributes["xmlns:gx"] = "http://www.google.com/kml/ext/2.2"
        }
        let kmlRoot = xmlDoc.addChild(name: "kml", attributes: attributes)

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
