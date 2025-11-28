//
//  StandardValueTests.swift
//  RCKML
//
//  Created by Ryan Linn on 11/28/25.
//

@testable import RCKML
import Testing

struct StandardValueTests {
    @Test func stringKmlValue() throws {
        let goodValue = "Hello"

        let kmlValue = try String(kmlString: goodValue)
        #expect(kmlValue == goodValue)
        #expect(kmlValue.kmlString == goodValue)

        #expect(throws: KMLValueDecodeError<String>.self) {
            _ = try String(kmlString: "")
        }
    }

    @Test func intKmlValue() throws {
        let zeroVal = try Int(kmlString: "0")
        #expect(zeroVal == 0)
        #expect(zeroVal.kmlString == "0")

        let randomNumber = Int.random(in: -100...100)
        let randomVal = try Int(kmlString: "\(randomNumber)")
        #expect(randomNumber == randomVal)
        #expect(randomVal.kmlString == "\(randomNumber)")

        #expect(throws: KMLValueDecodeError<Int>.self) {
            _ = try Int(kmlString: "hello")
        }
    }

    @Test func doubleKmlValue() throws {
        let zeroVal = try Double(kmlString: "0")
        #expect(zeroVal == 0.0)
        #expect(zeroVal.kmlString == "0.0")

        let randomNumber = Double.random(in: -100...100)
        let randomVal = try Double(kmlString: "\(randomNumber)")
        #expect(randomNumber == randomVal)
        #expect(randomVal.kmlString == "\(randomNumber)")

        #expect(throws: KMLValueDecodeError<Double>.self) {
            _ = try Double(kmlString: "hello")
        }
    }

    @Test func boolKmlValue() throws {
        let trueVal = try Bool(kmlString: "1")
        #expect(trueVal == true)
        #expect(trueVal.kmlString == "1")

        let falseVal = try Bool(kmlString: "0")
        #expect(falseVal == false)
        #expect(falseVal.kmlString == "0")

        #expect(throws: KMLValueDecodeError<Bool>.self) {
            _ = try Bool(kmlString: "true")
        }
    }
}
