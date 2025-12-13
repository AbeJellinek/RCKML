//
//  KMLFile.swift
//  RCKML
//
//  Created by Ryan Linn on 12/12/25.
//

/*
public struct KMLFile {
    public var features: [AnyKMLFeature]

    public init(_ data: Data) throws {
        let xmlDoc = try AEXMLDocument(xml: data)
        guard let documentElement = xmlDoc.firstDescendant(where: { $0.name == Self.kmlTag }) else {
            throw KMLDocumentError.missingDocumentRoot
        }
        let decoder = KMLDecoder(documentElement)
        try self.init(from: decoder)
    }

    public init(kmzData: Data) throws {
        var extractedData = Data()
        let archive = try Archive(data: kmzData, accessMode: .read, pathEncoding: .utf8)

        guard let kmlEntry = archive.first(where: { $0.path.hasSuffix("kml") }),
              let _ = try? archive.extract(kmlEntry, consumer: { extractedData += $0 }),
              !extractedData.isEmpty
        else {
            throw KMLDocumentError.kmzReadError
        }

        try self.init(extractedData)
    }

    public init(_ kmlString: String) throws {
        guard let data = kmlString.data(using: .utf8) else {
            throw KMLDocumentError.failedStringConversion
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
            throw KMLDocumentError.unknownFileExtension(url.pathExtension)
        }
    }


    /// Returns the full string representation of the KML file.
    public func kmlString() throws -> String {
        let xmlDoc = AEXMLDocument()
        let baseAttributes = ["xmlns" : "http://www.opengis.net/kml/2.2"]
        let kmlRoot = xmlDoc.addChild(name: "kml", attributes: baseAttributes)

        let encoder = KMLEncoder(kmlRoot)
        try encoder.encodeChild(self)

        return xmlDoc.xml
    }

    /// Returns the file data representation of the KML file.
    public func kmlData() throws -> Data {
        guard let result = try kmlString().data(using: .utf8) else {
            throw KMLDocumentError.failedStringConversion
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
            throw KMLDocumentError.kmzWriteError
        }
        return result
    }

}

enum KMLDocumentError: Error {
    case failedStringConversion
    case kmzReadError
    case kmzWriteError
    case missingDocumentRoot
    case unknownFileExtension(String)
}
*/
