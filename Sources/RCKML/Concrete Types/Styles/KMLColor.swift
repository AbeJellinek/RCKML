//
//  KMLColor.swift
//  RCKML
//
//  Created by Ryan Linn on 6/19/21.
//

import CoreGraphics

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

#if canImport(SwiftUI)
import SwiftUI
#endif

/// A struct representing the RGBa color value of a KML object's *color* tag.
///
/// For a brief discussion of KML's hex color coding, see [ColorStyle](https://developers.google.com/kml/documentation/kmlreference#colorstyle) reference.
public struct KMLColor {
    /// A value between 0.0 and 1.0 representing the Red element of the color
    public var red: Double

    /// A value between 0.0 and 1.0 representing the Green element of the color
    public var green: Double

    /// A value between 0.0 and 1.0 representing the Blue element of the color
    public var blue: Double

    /// A value between 0.0 and 1.0 representing the alpha element of the color
    public var alpha: Double

    public init(
        red: Double,
        green: Double,
        blue: Double,
        alpha: Double = 1.0
    ) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

// MARK: - Conversions

public extension KMLColor {
    var cgColor: CGColor {
        CGColor(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(alpha)
        )
    }

#if canImport(UIKit)
    var uiColor: UIColor {
        UIColor(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(alpha)
        )
    }

    init(_ uiColor: UIColor) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.red = Double(red)
        self.green = Double(green)
        self.blue = Double(blue)
        self.alpha = Double(alpha)
    }
#endif

#if canImport(AppKit)
    var nsColor: NSColor {
        NSColor(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(alpha)
        )
    }

    init(_ nsColor: NSColor) {
        red = Double(nsColor.redComponent)
        green = Double(nsColor.greenComponent)
        blue = Double(nsColor.blueComponent)
        alpha = Double(nsColor.alphaComponent)
    }
#endif

#if canImport(SwiftUI)
    var color: Color {
        Color(red: red, green: green, blue: blue)
            .opacity(alpha)
    }
#endif
}

// MARK: - KML Value Codable

extension KMLColor: KMLValue {
    enum Errors: Error, Equatable {
        case stringLength(String)
        case scannerFailure(String)
    }

    var kmlString: String {
        String(
            format: "%02lX%02lX%02lX%02lX",
            lroundf(Float(alpha) * 255),
            lroundf(Float(blue) * 255),
            lroundf(Float(green) * 255),
            lroundf(Float(red) * 255)
        )
    }

    init(kmlString: String) throws {
        let formattedString = kmlString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        
        guard formattedString.count == 8 else {
            throw Errors.stringLength(formattedString)
        }

        // Inner function to get Double value for pair of characters starting at
        // given index
        func byte(_ index: Int) throws -> Double {
            let start = formattedString.index(formattedString.startIndex, offsetBy: index)
            let end = formattedString.index(start, offsetBy: 1)
            let subString = formattedString[start...end]
            guard let val = UInt8(subString, radix: 16) else {
                throw Errors.scannerFailure(String(subString))
            }
            return Double(val) / 255.0
        }

        alpha = try byte(0)
        blue = try byte(2)
        green = try byte(4)
        red = try byte(6)
    }
}
