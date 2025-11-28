//
//  KMLColorValueTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/28/25.
//

@testable import RCKML
import Testing

struct KMLColorValueTests {
    @Test func rgbaToKmlString() {
        let black = KMLColor(red: 0, green: 0, blue: 0, alpha: 1)
        #expect(black.kmlString.lowercased() == "ff000000")

        let white = KMLColor(red: 1, green: 1, blue: 1, alpha: 1)
        #expect(white.kmlString.lowercased() == "ffffffff")

        let red = KMLColor(red: 1, green: 0, blue: 0, alpha: 1)
        #expect(red.kmlString.lowercased() == "ff0000ff")

        let green = KMLColor(red: 0, green: 1, blue: 0, alpha: 1)
        #expect(green.kmlString.lowercased() == "ff00ff00")

        let blue = KMLColor(red: 0, green: 0, blue: 1, alpha: 1)
        #expect(blue.kmlString.lowercased() == "ffff0000")

        let clear = KMLColor(red: 0, green: 0, blue: 0, alpha: 0)
        #expect(clear.kmlString.lowercased() == "00000000")

        let translucentRed = KMLColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        #expect(translucentRed.kmlString.lowercased() == "800000ff")
    }

    @Test func kmlStringToRgba() throws {
        let black = try KMLColor(kmlString: "ff000000")
        #expect(black.alpha == 1.0)
        #expect(black.red == 0.0)
        #expect(black.green == 0.0)
        #expect(black.blue == 0.0)

        let white = try KMLColor(kmlString: "ffffffff")
        #expect(white.alpha == 1.0)
        #expect(white.red == 1.0)
        #expect(white.green == 1.0)
        #expect(white.blue == 1.0)

        let red = try KMLColor(kmlString: "ff0000ff")
        #expect(red.alpha == 1.0)
        #expect(red.red == 1.0)
        #expect(red.green == 0.0)
        #expect(red.blue == 0.0)

        let green = try KMLColor(kmlString: "FF00ff00")
        #expect(green.alpha == 1.0)
        #expect(green.red == 0.0)
        #expect(green.green == 1.0)
        #expect(green.blue == 0.0)

        let blue = try KMLColor(kmlString: "FFFF0000")
        #expect(blue.alpha == 1.0)
        #expect(blue.red == 0.0)
        #expect(blue.green == 0.0)
        #expect(blue.blue == 1.0)

        let clear = try KMLColor(kmlString: "00000000")
        #expect(clear.alpha == 0.0)
        #expect(clear.red == 0.0)
        #expect(clear.green == 0.0)
        #expect(clear.blue == 0.0)

        let translucentRed = try KMLColor(kmlString: "800000ff")
        #expect((translucentRed.alpha - 0.5).magnitude < 0.02, "translucentRed.alpha should be 0.5, was \(translucentRed.alpha)")
        #expect(translucentRed.red == 1.0)
        #expect(translucentRed.green == 0)
        #expect(translucentRed.blue == 0)
    }

    @Test func failingKmlStringToRgba() {
        #expect(throws: KMLColor.Errors.stringLength("")) {
            _ = try KMLColor(kmlString: "  \n  ")
        }

        #expect(throws: KMLColor.Errors.stringLength("FFFF")) {
            _ = try KMLColor(kmlString: "ffff")
        }

        #expect(throws: KMLColor.Errors.scannerFailure("GH")) {
            _ = try KMLColor(kmlString: "abcdefgh")
        }
    }
}
