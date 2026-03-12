//
//  KMLTrackTests.swift
//  RCKML
//

import AEXML
@testable import RCKML
import Testing
import Foundation

struct KMLTrackTests {
    // MARK: - Decode

    @Test func decodeTrackWithAltitude() throws {
        let decoder = try KMLDecoder(testXml: """
            <gx:Track id="track1">
            <when>2024-01-15T10:00:00Z</when>
            <when>2024-01-15T10:00:30Z</when>
            <when>2024-01-15T10:01:00Z</when>
            <gx:coord>-112.9 37.3 1500.0</gx:coord>
            <gx:coord>-112.8 37.4 1520.0</gx:coord>
            <gx:coord>-112.7 37.5 1540.0</gx:coord>
            </gx:Track>
            """)
        let track = try decoder.decode(KMLTrack.self)

        #expect(track.id == "track1")
        #expect(track.coordinates.count == 3)
        #expect(track.timestamps.count == 3)
        #expect(track.coordinates[0].longitude == -112.9)
        #expect(track.coordinates[0].latitude == 37.3)
        #expect(track.coordinates[0].altitude == 1500.0)
        #expect(track.coordinates[2].longitude == -112.7)
    }

    @Test func decodeTrackWithoutAltitude() throws {
        let decoder = try KMLDecoder(testXml: """
            <gx:Track>
            <when>2024-01-15T10:00:00Z</when>
            <when>2024-01-15T10:00:30Z</when>
            <gx:coord>-112.9 37.3</gx:coord>
            <gx:coord>-112.8 37.4</gx:coord>
            </gx:Track>
            """)
        let track = try decoder.decode(KMLTrack.self)

        #expect(track.coordinates.count == 2)
        #expect(track.timestamps.count == 2)
        #expect(track.coordinates[0].altitude == nil)
    }

    @Test func decodeTrackWithFractionalSeconds() throws {
        let decoder = try KMLDecoder(testXml: """
            <gx:Track>
            <when>2024-01-15T10:00:00.123Z</when>
            <gx:coord>-112.9 37.3 1500.0</gx:coord>
            </gx:Track>
            """)
        let track = try decoder.decode(KMLTrack.self)

        #expect(track.timestamps.count == 1)
    }

    @Test func failDecodeWrongTag() throws {
        let decoder = try KMLDecoder(testXml: "<LineString><coordinates>0,0</coordinates></LineString>")
        #expect(throws: (any Error).self) {
            let _ = try decoder.decode(KMLTrack.self)
        }
    }

    // MARK: - Encode

    @Test func encodeTrack() throws {
        let coords = [
            KMLCoordinate(latitude: 37.3, longitude: -112.9, altitude: 1500.0),
            KMLCoordinate(latitude: 37.4, longitude: -112.8, altitude: 1520.0),
        ]
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let timestamps = [
            formatter.date(from: "2024-01-15T10:00:00Z")!,
            formatter.date(from: "2024-01-15T10:00:30Z")!,
        ]
        let track = KMLTrack(id: "track1", coordinates: coords, timestamps: timestamps)
        let encoder = try KMLEncoder(wrapping: track)

        let xml = encoder.xml
        #expect(xml.name == "gx:Track")
        #expect(xml.attributes["id"] == "track1")

        let whens = xml.children(named: "when")
        #expect(whens.count == 2)
        #expect(whens[0].string == "2024-01-15T10:00:00Z")
        #expect(whens[1].string == "2024-01-15T10:00:30Z")

        let gxCoords = xml.children(named: "gx:coord")
        #expect(gxCoords.count == 2)
        // Verify space-separated lon lat alt format
        #expect(gxCoords[0].string.contains("-112.9"))
        #expect(gxCoords[0].string.contains("37.3"))
        #expect(gxCoords[0].string.contains("1500"))
    }

    @Test func encodeTrackWithoutAltitude() throws {
        let coords = [
            KMLCoordinate(latitude: 37.3, longitude: -112.9),
        ]
        let timestamps = [Date()]
        let track = KMLTrack(coordinates: coords, timestamps: timestamps)
        let encoder = try KMLEncoder(wrapping: track)

        let gxCoords = encoder.xml.children(named: "gx:coord")
        #expect(gxCoords.count == 1)
        // Should NOT contain a third space-separated component
        let parts = gxCoords[0].string.components(separatedBy: " ").filter { !$0.isEmpty }
        #expect(parts.count == 2)
    }

    // MARK: - Round-trip

    @Test func roundTrip() throws {
        let coords = [
            KMLCoordinate(latitude: 37.3, longitude: -112.9, altitude: 1500.0),
            KMLCoordinate(latitude: 37.4, longitude: -112.8, altitude: 1520.0),
        ]
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let timestamps = [
            formatter.date(from: "2024-01-15T10:00:00Z")!,
            formatter.date(from: "2024-01-15T10:00:30Z")!,
        ]
        let original = KMLTrack(coordinates: coords, timestamps: timestamps)

        // Encode
        let encoder = try KMLEncoder(wrapping: original)
        let xmlString = encoder.xml.xml

        // Decode
        let decoder = try KMLDecoder(testXml: xmlString)
        let decoded = try decoder.decode(KMLTrack.self)

        #expect(decoded.coordinates.count == original.coordinates.count)
        #expect(decoded.timestamps.count == original.timestamps.count)
        for i in 0..<coords.count {
            #expect(decoded.coordinates[i].latitude == original.coordinates[i].latitude)
            #expect(decoded.coordinates[i].longitude == original.coordinates[i].longitude)
            #expect(decoded.coordinates[i].altitude == original.coordinates[i].altitude)
            #expect(decoded.timestamps[i] == original.timestamps[i])
        }
    }

    // MARK: - gx:coord parsing

    @Test func gxCoordParsing() throws {
        let coord = try KMLCoordinate(gxCoord: "-122.207881 37.371915 156.0")
        #expect(coord.longitude == -122.207881)
        #expect(coord.latitude == 37.371915)
        #expect(coord.altitude == 156.0)
    }

    @Test func gxCoordParsingNoAltitude() throws {
        let coord = try KMLCoordinate(gxCoord: "-122.207881 37.371915")
        #expect(coord.longitude == -122.207881)
        #expect(coord.latitude == 37.371915)
        #expect(coord.altitude == nil)
    }

    @Test func gxCoordParsingBadInput() {
        #expect(throws: GxCoordParseError.self) {
            _ = try KMLCoordinate(gxCoord: "just-one-value")
        }
    }

    // MARK: - AnyKMLGeometry integration

    @Test func decodeAsAnyGeometry() throws {
        let decoder = try KMLDecoder(testXml: Samples.Geometries.trackXml)
        let anyGeometry = try decoder.decode(AnyKMLGeometry.self)
        switch anyGeometry {
        case .track(let track):
            #expect(track.coordinates.count == 2)
            #expect(track.timestamps.count == 2)
        default:
            Issue.record("Expected .track, got \(anyGeometry)")
        }
    }

    @Test func encodeAsAnyGeometry() throws {
        let track = KMLTrack(
            coordinates: [.sampleA, .sampleB],
            timestamps: [Date(), Date()]
        )
        let anyGeometry = try AnyKMLGeometry(track)
        let encoder = try KMLEncoder(wrapping: anyGeometry)
        #expect(encoder.xml.name == "gx:Track")
    }

    // MARK: - KMLFile xmlns:gx

    @Test func kmlFileOmitsGxNamespaceWithoutTracks() throws {
        let placemark = KMLPlacemark.sampleWithPoint()
        let doc = try KMLDocument(name: "Test", features: [placemark])
        let file = try KMLFile(features: [doc])
        let xml = try file.kmlString()
        #expect(!xml.contains("xmlns:gx"))
    }

    @Test func kmlFileIncludesGxNamespaceWithTrack() throws {
        let track = KMLTrack(
            coordinates: [.sampleA, .sampleB],
            timestamps: [Date(), Date()]
        )
        let placemark = KMLPlacemark(name: "Track", geometry: .track(track))
        let doc = try KMLDocument(name: "Test", features: [placemark])
        let file = try KMLFile(features: [doc])
        let xml = try file.kmlString()
        #expect(xml.contains("xmlns:gx"))
    }

    // MARK: - Full file round-trip

    @Test func fullFileRoundTrip() throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let track = KMLTrack(
            coordinates: [
                KMLCoordinate(latitude: 37.3, longitude: -112.9, altitude: 1500.0),
                KMLCoordinate(latitude: 37.4, longitude: -112.8, altitude: 1520.0),
            ],
            timestamps: [
                formatter.date(from: "2024-01-15T10:00:00Z")!,
                formatter.date(from: "2024-01-15T10:00:30Z")!,
            ]
        )
        let placemark = KMLPlacemark(name: "Hike", geometry: .track(track))
        let doc = try KMLDocument(name: "Export", features: [placemark])
        let file = try KMLFile(features: [doc])

        // Write and re-read
        let data = try file.kmlData()
        let reloaded = try KMLFile(data)

        guard case .document(let reDoc) = reloaded.features.first else {
            Issue.record("Expected document")
            return
        }
        guard case .placemark(let rePm) = reDoc.features.first else {
            Issue.record("Expected placemark")
            return
        }
        guard case .track(let reTrack) = rePm.geometry else {
            Issue.record("Expected track geometry, got \(String(describing: rePm.geometry))")
            return
        }
        #expect(reTrack.coordinates.count == 2)
        #expect(reTrack.timestamps.count == 2)
        #expect(reTrack.coordinates[0].latitude == 37.3)
        #expect(reTrack.timestamps[0] == formatter.date(from: "2024-01-15T10:00:00Z"))
    }
}
