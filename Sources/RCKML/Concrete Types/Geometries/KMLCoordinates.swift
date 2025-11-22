//
//  KMLCoordinates.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

/// A single point on Earth represented by latitude and longitude,  plus an optional altitude (expressed in
/// meters above sea level).
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

// MARK: - KMLValue

struct CoordinateParseError: Error {}

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

// MARK: - Array<KMLCoordinate> as KMLValue

extension Array: KMLValue where Element == KMLCoordinate {
    var kmlString: String {
        map(\.description)
            .joined(separator: " ")
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
