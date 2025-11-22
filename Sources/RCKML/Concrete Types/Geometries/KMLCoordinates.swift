//
//  KMLCoordinates.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

import AEXML
import Foundation

// MARK: - Individual Coordinate Struct

/// A single point on Earth represented by latitude and longitude,
/// plus an optional altitude (expressed in meters above sea level).
///
/// In KML instances of KMLGeometry, coordinates are usually represented
/// as an array of KMLCoordinate, although in reading or writing
/// geometries to/from KML files they are stored as KMLCoordinateSequence.
///
/// - SeeAlso:
/// KMLCoordinateSequence
public struct KMLCoordinate {
    public var latitude: Double
    public var longitude: Double
    public var altitude: Double?

    public init(
        latitude: Double,
        longitude: Double,
        altitude: Double? = nil
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }
}

// MARK: CustomStringConvertible

extension KMLCoordinate: CustomStringConvertible {
    public var description: String {
        if let altitude = altitude {
            String(format: "%6f,%.6f,%.1f", longitude, latitude, altitude)
        } else {
            String(format: "%.6f,%.6f", longitude, latitude)
        }
    }
}

struct CoordinateParseError: Error {}

// MARK: - KMLValue

extension KMLCoordinate: KMLValue {
    var kmlString: String {
        description
    }
    
    init(kmlString: String) throws {
        let components = kmlString.components(separatedBy: ",")

        guard components.count >= 2 else {
            throw CoordinateParseError()
        }

        longitude = Double(components[0])!
        latitude = Double(components[1])!
        altitude = components.count > 2 ? Double(components[2]) : nil
    }
}

// MARK: - Coordinate Array as KMLValue

extension Array: KMLValue where Element == KMLCoordinate {
    var kmlString: String {
        map(\.description)
            .joined(separator: "\n")
    }

    init(kmlString: String) throws {
        let splits = kmlString.components(separatedBy: .whitespacesAndNewlines)

        let coords = splits.compactMap { str -> KMLCoordinate? in
            try? KMLCoordinate(kmlString: str)
        }

        if coords.isEmpty {
            throw CoordinateParseError()
        }
        self = coords
    }
}
