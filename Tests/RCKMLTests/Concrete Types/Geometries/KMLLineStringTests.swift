//
//  KMLLineStringTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/30/25.
//

import AEXML
@testable import RCKML
import Testing

struct KMLLineStringTests {
    @Test func successfulDecode() throws {
        let decoder = try KMLDecoder(testXml: """
            <LineString id="LineString1">
            <coordinates>
            1.0,2.0
            3.0,4.0
            </coordinates>
            </LineString>
            """)
        let lineString = try decoder.decode(KMLLineString.self)

        #expect(lineString.id == "LineString1")
        #expect(lineString.coordinates.count == 2)
    }

    @Test func failedDecode() throws {
        let decoder = try KMLDecoder(testXml: "<LineString></LineString>")
        #expect(throws: KMLDecoderError.self) {
            let _ = try decoder.decode(KMLLineString.self)
        }
    }
}
