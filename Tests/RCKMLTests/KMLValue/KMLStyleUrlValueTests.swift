//
//  KMLStyleUrlValueTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/28/25.
//

@testable import RCKML
import Testing

@Test func styleUrlTests() throws {
    let direct = KMLStyleUrl(styleId: "myId")
    let fromKml = try KMLStyleUrl(kmlString: "#myId")
    #expect(direct == fromKml)
    #expect(fromKml.styleId == "myId")
    #expect(direct.kmlString == "#myId")
}
