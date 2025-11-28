//
//  KMLCoordinateValueTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/28/25.
//

@testable import RCKML
import Testing

struct KMLCoordinateValueTests {
    @Test func stringToCoordinate() throws {
        let noAltitude = try KMLCoordinate(kmlString: "1.0,2.0")
        #expect(noAltitude.longitude == 1.0)
        #expect(noAltitude.latitude == 2.0)
        #expect(noAltitude.altitude == nil)

        let withAltitude = try KMLCoordinate(kmlString: "1.0,2.0,3.0")
        #expect(withAltitude.longitude == 1.0)
        #expect(withAltitude.latitude == 2.0)
        #expect(withAltitude.altitude == 3.0)

        #expect(throws: CoordinateParseError.incorrectComponentCount("abc")) {
            _ = try KMLCoordinate(kmlString: "abc")
        }

        #expect(throws: CoordinateParseError.incorrectComponentCount("a,b,c,d")) {
            _ = try KMLCoordinate(kmlString: "a,b,c,d")
        }

        #expect(throws: CoordinateParseError.noDoubleValue("a")) {
            _ = try KMLCoordinate(kmlString: "a,b")
        }

        #expect(throws: CoordinateParseError.noDoubleValue("a")) {
            _ = try KMLCoordinate(kmlString: "1.0,2,a")
        }
    }

    @Test func coordinateToString() throws {
        let noAltitude = KMLCoordinate(latitude: 1.0, longitude: 2.0)
        #expect(noAltitude.kmlString == "2.0,1.0")

        let withAltitude = KMLCoordinate(latitude: 1.0, longitude: 2.0, altitude: 3.0)
        #expect(withAltitude.kmlString == "2.0,1.0,3.0")
    }

    @Test func stringToMultiCoordinate() throws {
        let noAltitude = try [KMLCoordinate](kmlString: "1.0,2.0 3.0,4.0")
        #expect(noAltitude.count == 2)
        #expect(noAltitude.first == KMLCoordinate(latitude: 2.0, longitude: 1.0))
        #expect(noAltitude.last == KMLCoordinate(latitude: 4.0, longitude: 3.0))

        let withAltitude = try [KMLCoordinate](kmlString: "1.0,2.0,3.0 4.0,5.0,6.0")
        #expect(withAltitude.count == 2)
        #expect(withAltitude.first == KMLCoordinate(latitude: 2.0, longitude: 1.0, altitude: 3.0))
        #expect(withAltitude.last == KMLCoordinate(latitude: 5.0, longitude: 4.0, altitude: 6.0))

        #expect(throws: CoordinateParseError.emptyCoordinates) {
            _ = try [KMLCoordinate](kmlString: "")
        }

        #expect(throws: CoordinateParseError.incorrectComponentCount("4")) {
            _ = try [KMLCoordinate](kmlString: "1,2,3 4")
        }

        #expect(throws: CoordinateParseError.noDoubleValue("a")) {
            _ = try [KMLCoordinate](kmlString: "1,2,3 a,b,c")
        }
    }

    @Test func multiCoordinateToString() throws {
        let withAltitude = [
            KMLCoordinate(latitude: 2.0, longitude: 1.0, altitude: 3.0),
            KMLCoordinate(latitude: 5.0, longitude: 4.0, altitude: 6.0)
        ]
        #expect(withAltitude.kmlString == "1.0,2.0,3.0 4.0,5.0,6.0")

        let noAltitude = [
            KMLCoordinate(latitude: 2.0, longitude: 1.0),
            KMLCoordinate(latitude: 4.0, longitude: 3.0)
        ]
        #expect(noAltitude.kmlString == "1.0,2.0 3.0,4.0")
    }
}
