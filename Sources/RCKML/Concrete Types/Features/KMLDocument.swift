//
//  KMLDocument.swift
//  RCKML
//
//  Created by Ryan Linn on 6/18/21.
//

import AEXML
import Foundation
import ZIPFoundation

/// A root object for reading KML from file, or writing to file.
///
/// At its base, the KMLDocument is an array of KMLFeatures, and a dictionary
/// of `[StyleUrl : StyleSelector]` which are used as global styles for the
/// features in the file.
///
/// KMLDocuments can be initialized from either raw data, a fileUrl, or a KML string.
///
/// To export a KMLDocument, use the functions `kmlString()` or `kmlData()`
public struct KMLDocument: KMLObject, KMLContainer {
    public var id: String?
    public var name: String?
    public var featureDescription: String?
    public var features: [SomeKMLFeature]

//    public var styles: [KMLStyleUrl : KMLStyleSelector]
    public var styles: [SomeKMLStyleSelector]


    public static var kmlTag: String {
        "Document"
    }

    public init(
        id: String? = nil,
        name: String? = nil,
        featureDescription: String? = nil,
        features: [SomeKMLFeature] = [],
        styles: [SomeKMLStyleSelector] = []
    ) {
        self.id = id
        self.name = name
        self.featureDescription = featureDescription
        self.features = features
        self.styles = styles
    }
}

// MARK: - Errors

enum KMLDocumentError: Error {
    case failedStringConversion
    case kmzReadError
    case kmzWriteError
    case missingDocumentRoot
    case unknownFileExtension(String)
}

// MARK: - Accessors

public extension KMLDocument {
    /// Returns the full string representation of the KML file.
    func kmlString() throws -> String {
        let xmlDoc = AEXMLDocument()
        let baseAttributes = ["xmlns" : "http://www.opengis.net/kml/2.2"]
        let kmlRoot = xmlDoc.addChild(name: "kml", attributes: baseAttributes)

        let encoder = KMLEncoder(kmlRoot)
        try encoder.encodeChild(self)

        return xmlDoc.xml
    }

    /// Returns the file data representation of the KML file.
    func kmlData() throws -> Data {
        guard let result = try kmlString().data(using: .utf8) else {
            throw KMLDocumentError.failedStringConversion
        }
        return result
    }

    /// Returns the file data representation as a KMZ file.
    func kmzData() throws -> Data {
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

    /// Given a KMLStyleUrl reference from a feature contained in this document,
    /// returns the global style that is referenced by the url.
    func getStyleFromUrl(_ styleUrl: KMLStyleUrl) -> KMLStyle? {
        guard let aSelector = styles.first(where: { $0.wrapped.id == styleUrl.styleId }) else {
            return nil
        }
        switch aSelector {
        case .styleMap(let styleMap):
            switch styleMap.content {
            case .styleUrl(let styleUrl):
                return getStyleFromUrl(styleUrl)
            case .style(let mapStyle):
                return mapStyle
            }
        case .style(let style):
            return style
        }
    }
}

// MARK: - Initializers

public extension KMLDocument {
    init(_ data: Data) throws {
        let xmlDoc = try AEXMLDocument(xml: data)
        guard let documentElement = xmlDoc.firstDescendant(where: { $0.name == Self.kmlTag }) else {
            throw KMLDocumentError.missingDocumentRoot
        }
        let decoder = KMLDecoder(documentElement)
        try self.init(from: decoder)
    }

    init(kmzData: Data) throws {
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

    init(_ kmlString: String) throws {
        guard let data = kmlString.data(using: .utf8) else {
            throw KMLDocumentError.failedStringConversion
        }
        try self.init(data)
    }

    /// Initializes a KMLDocument from a fileUrl, which must have a
    /// path extension of either "KML" or "KMZ" (neither are case-sensitive).
    /// - Throws: KML reading errors.
    init(_ url: URL) throws {
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

    /*
    /// Given the root XML element of a KML file, this returns the `styles`
    /// property for the KMLDocument.
    private static func kmlStylesInElement(_ xmlElement: AEXMLElement) throws -> [KMLStyleUrl: KMLStyleSelector] {
        // return array of StyleMap and Style
        let styleMaps = try xmlElement[KMLStyleMap.kmlTag].all?.map { try KMLStyleMap(xml: $0) } ?? []
        let styleElements = xmlElement[KMLStyle.kmlTag].all ?? []
        let styles = styleElements.compactMap { try? KMLStyle(xml: $0) }
        let all: [KMLStyleSelector] = styles + styleMaps

        return all.reduce(into: [:]) { dict, style in
            if let styleId = style.id {
                let styleUrl = KMLStyleUrl(styleId: styleId)
                if let baseStyle = style as? KMLStyle,
                   baseStyle.isEmpty == true
                {
                    dict[styleUrl] = nil
                } else {
                    dict[styleUrl] = style
                }
            }
        }
    }
     */
}

// MARK: - KMLCodable

extension KMLDocument: KMLDecodable {
    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute
        name = try? decoder.value(of: String.self, forKey: .name)
        featureDescription = try? decoder.value(of: String.self, forKey: .description)

        features = try decoder.allChildren(of: SomeKMLFeature.self)
        styles = try decoder.allChildren(of: SomeKMLStyleSelector.self)
    }
}

extension KMLDocument: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        try encoder.encode(tag: .name, value: name)
        try encoder.encode(tag: .description, value: featureDescription)
        for feature in features {
            try encoder.encodeChild(feature)
        }
        for styleSelector in styles {
            try encoder.encodeChild(styleSelector)
        }
    }
}
