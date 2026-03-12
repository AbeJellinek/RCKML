//
//  KMLTrack.swift
//  RCKML
//
//  Google Earth extension (gx:Track) — a series of coordinates with paired timestamps.
//
//  Format:
//  ```xml
//  <gx:Track>
//    <when>2010-05-28T02:02:09Z</when>
//    <when>2010-05-28T02:02:35Z</when>
//    <gx:coord>-122.207881 37.371915 156.0</gx:coord>
//    <gx:coord>-122.205712 37.373288 152.0</gx:coord>
//  </gx:Track>
//  ```
//
//  Note: `gx:coord` uses space-separated `lon lat alt` (not comma-separated like `<coordinates>`).

import Foundation

/// A timestamped track geometry from the Google Earth `gx:` extension namespace.
public struct KMLTrack: KMLGeometry {
    public var id: String?
    public var coordinates: [KMLCoordinate]
    public var timestamps: [Date]

    public init(
        id: String? = nil,
        coordinates: [KMLCoordinate],
        timestamps: [Date]
    ) {
        self.id = id
        self.coordinates = coordinates
        self.timestamps = timestamps
    }

    public static var kmlTag: String {
        "gx:Track"
    }
}

// MARK: - gx:coord parsing

enum GxCoordParseError: Error {
    case incorrectComponentCount(String)
    case noDoubleValue(String)
}

extension KMLCoordinate {
    /// Parse a `gx:coord` value: space-separated `lon lat [alt]`.
    init(gxCoord string: String) throws {
        let parts = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }

        guard parts.count == 2 || parts.count == 3 else {
            throw GxCoordParseError.incorrectComponentCount(string)
        }
        guard let lon = Double(parts[0]) else {
            throw GxCoordParseError.noDoubleValue(parts[0])
        }
        guard let lat = Double(parts[1]) else {
            throw GxCoordParseError.noDoubleValue(parts[1])
        }
        self.longitude = lon
        self.latitude = lat
        if parts.count == 3, let alt = Double(parts[2]) {
            self.altitude = alt
        } else {
            self.altitude = nil
        }
    }

    /// Encode as a `gx:coord` value: space-separated `lon lat [alt]`.
    var gxCoordString: String {
        var s = "\(coordFormat(longitude)) \(coordFormat(latitude))"
        if let alt = altitude {
            s += " \(coordFormat(alt))"
        }
        return s
    }

    /// Format a coordinate component without locale grouping separators.
    private func coordFormat(_ value: Double) -> String {
        let format = FloatingPointFormatStyle<Double>.number
            .precision(.fractionLength(1...6))
            .grouping(.never)
            .locale(Locale(identifier: "en_US_POSIX"))
        return value.formatted(format)
    }
}

// MARK: - KML Codable

extension KMLTrack: KMLDecodable {
    init(from decoder: KMLDecoder) throws {
        try decoder.verifyMatchesType(Self.self)
        id = decoder.idAttribute

        let whenStrings = decoder.decodeAll(forKey: .when)
        let coordStrings = decoder.decodeAll(forKey: .gxCoord)

        coordinates = try coordStrings.map { try KMLCoordinate(gxCoord: $0) }
        timestamps = whenStrings.compactMap { Self.parseDate($0) }
    }

    private static func parseDate(_ string: String) -> Date? {
        let full = ISO8601DateFormatter()
        full.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = full.date(from: string) { return date }
        full.formatOptions = [.withInternetDateTime]
        return full.date(from: string)
    }
}

extension KMLTrack: KMLEncodable {
    func encode(to encoder: KMLEncoder) throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        for i in 0..<coordinates.count {
            if i < timestamps.count {
                encoder.encodeAppend(tag: .when, value: formatter.string(from: timestamps[i]))
            }
            encoder.encodeAppend(tag: .gxCoord, value: coordinates[i].gxCoordString)
        }
    }
}
