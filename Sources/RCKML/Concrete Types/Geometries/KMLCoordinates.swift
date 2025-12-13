//
//  KMLCoordinates.swift
//  RCKML
//
//  Created by Ryan Linn on 6/17/21.
//

import Foundation

/// A single point on Earth represented by latitude and longitude,  plus an optional altitude (expressed in
/// meters above sea level).
public struct KMLCoordinate: Equatable {
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

// MARK: - KMLValue

enum CoordinateParseError: Error, Equatable {
    case incorrectComponentCount(String)
    case noDoubleValue(String)
    case emptyCoordinates
}

extension KMLCoordinate: KMLValue {
    private static let coordinateFormat = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(1...6))

    var kmlString: String {
        let lonString = longitude.formatted(Self.coordinateFormat)
        let latString = latitude.formatted(Self.coordinateFormat)
        let altString = altitude.flatMap { $0.formatted(.number.precision(.fractionLength(1))) }
        return [lonString, latString, altString].compactMap(\.self).joined(separator: ",")
    }
    
    init(kmlString: String) throws {
        let components = kmlString.components(separatedBy: ",")

        guard components.count == 2 || components.count == 3 else {
            throw CoordinateParseError.incorrectComponentCount(kmlString)
        }

        guard let lon = Double(components[0]) else {
            throw CoordinateParseError.noDoubleValue(components[0])
        }
        self.longitude = lon

        guard let lat = Double(components[1]) else {
            throw CoordinateParseError.noDoubleValue(components[1])
        }
        self.latitude = lat

        if components.count == 3 {
            if let alt = Double(components[2]) {
                altitude = alt
            } else {
                throw CoordinateParseError.noDoubleValue(components[2])
            }
        } else {
            altitude = nil
        }
    }
}

// MARK: - Array<KMLCoordinate> as KMLValue

extension Array: KMLValue where Element == KMLCoordinate {
    var kmlString: String {
        map(\.kmlString)
            .joined(separator: " ")
    }

    init(kmlString: String) throws {
        let splits = kmlString
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        guard !splits.isEmpty else {
            throw CoordinateParseError.emptyCoordinates
        }

        let coords = try splits.map { str -> KMLCoordinate in
            try KMLCoordinate(kmlString: str)
        }

        self = coords
    }
}
