## RCKML

![GitHub](https://img.shields.io/github/license/RCCoop/RCKML)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FRCCoop%2FRCKML%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/RCCoop/RCKML)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FRCCoop%2FRCKML%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/RCCoop/RCKML)

RCKML is a Swift library for reading and writing KML/KMZ files, built for simplicity and ease of use.

## Index:

- [Installation](#installation)
- [Core Types](#core-types)
- [AnyKML Types](#anykml-types)
- [Creating a KML File](#creating-a-kml-file)
- [Reading an existing KML file](#reading-an-existing-kml-file)
- [Geometries](#geometries)
- [Styles](#styles)
- [Further To-Do's](#further-to-dos)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

---

## Installation

Add RCKML to your project or package with Swift Package Manager:

```
https://github.com/RCCoop/RCKML.git
```

---

## Core Types

All types use [Google's KML Reference](https://developers.google.com/kml/documentation/kmlreference) as their source material. _Not all types are supported with all options available to KML files_. I've focused on types and features that can be easily translated into MapKit, but may add further types over time.

- **`KMLFile`**
  File-level wrapper used to read and write KML/KMZ data. Contains an array of `AnyKMLFeature`, which typically consists of a single `KMLDocument`.

- **Features**
  - `KMLDocument`: A container that can contain other features and shared styles (`KMLStyle`, `KMLStyleMap`).
  - `KMLPlacemark`: A feature associated with a geometry and optional style.
  - `KMLFolder`: A container feature that holds other features (including sub-folders).

- **Geometries**
  - `KMLPoint`: Single coordinate.
  - `KMLLineString`: Series of coordinates forming a path.
  - `KMLPolygon`: Polygon with outer and optional inner rings.
  - `KMLMultiGeometry`: Collection of other geometries.
  - `KMLCoordinate`: Latitude/longitude (+ optional altitude) value.

- **Styles**
  - `KMLStyle`: Aggregates styling such as `KMLLineStyle` and `KMLPolyStyle`.
  - `KMLStyleMap`: Maps between “normal” and “highlight” styles.
  - `KMLStyleUrl`: References a shared style by ID.
  - `KMLColor`: Encodes/decodes KML hex color values and bridges to platform colors.

## AnyKML Types

The library uses type-erased wrappers such as `AnyKMLFeature`, `AnyKMLGeometry`, and `AnyKMLStyleSelector` to allow heterogeneous collections while keeping the public API strongly typed.

You can use an `AnyKML` type through pattern matching, or by unwrapping its wrapped value. For example:

```swift
let somePlacemark: KMLPlacemark

// pattern-matching:
switch somePlacemark.geometry {
case .point(let point):
    // do something with `KMLPoint`
case .lineString(let lineString):
    // do something with `KMLLineString`
case .polygon(let polygon):
    // do something with `KMLPolygon`
case .multiGeometry(let multi):
    // do something with `KMLMultiGeometry`
}

// unwrapping:
let anyGeometry: (any KMLGeometry)? = somePlacemark.geometry?.wrapped
if let point = anyGeometry as? KMLPoint {
    // do something with `KMLPoint`
} else if let lineString = anyGeometry as? KMLLineString {
    // do something with `KMLLineString`
} else if let polygon = anyGeometry as? KMLPolygon {
    // do something with `KMLPolygon`
} else if let multiGeometry = anyGeometry as? KMLMultiGeometry {
    // do something with `KMLMultiGeometry`
}
```

Most KML types that can be initialized with an AnyKML type can also be initialized with the raw types:

```swift
let point: KMLPoint

// initialize Placemark with AnyKMLGeometry.point:
let placemarkA = KMLPlacemark(geometry: .point(point))

// Or with just the Point as a geometry (note, this initializer throws):
let placemarkB = try KMLPlacemark(geometry: point)
```

---

## Creating a KML File

This example creates a document with a single point placemark and writes it to disk as `.kml` and `.kmz`.

```swift
// Create a geometry
let point = KMLPoint(
    latitude: 38.897988,
    longitude:  -77.036439
)

// Wrap it in a Placemark
let placemark = try KMLPlacemark(
    id: "whiteHouse",
    name: "The White House",
    featureDescription: "The residence of the President of the United States.",
    geometry: point
)

// Create a KMLDocument and wrap the placemark
let document = try KMLDocument(
    name: "Sample Document",
    features: [placemark]
)

// Create a KMLFile
let file = try KMLFile(features: [document])

// Create and write data
let kmlData = try file.kmlData()
try kmlData.write(to: URL(fileURLWithPath: "/path/to/Sample.kml"))

let kmzData = try file.kmzData()
try kmzData.write(to: URL(fileURLPath: "/path/to/Sample.kmz"))
```

## Reading an existing KML file

```swift
let url = URL(fileURLWithPath: "/path/to/Existing.kml") // or .kmz

// KMLFile chooses the correct decoding path based on the extension
let file = try KMLFile(url)

// iterate through the file's features, and sub-features's features.
for feature in file.features {
    switch feature {
    case .document(let document):
        for nested in document.features {
            switch nested {
            case .placemark(let placemark):
                // do something with `KMLPlacemark`
            case .folder(let folder):
                // do something with `KMLFolder`
            case .document(let subdocument):
                // do something with `KMLDocument`
            }
        }

    case .folder(let folder):
        // do something with `KMLFolder`

    case .placemark(let placemark):
        // do something with `KMLPlacemark`
    }
}
```

---

## Geometries

### Point

Represents a single location on the map.

```swift
let point = KMLPoint(
    latitude: 38.897988,
    longitude:  -77.036439,
    altitude: nil
)
```

### LineString

Represents a connected series of locations, drawn as a line on the map.

```swift
let coordinates: [KMLCoordinate] = [
    KMLCoordinate(latitude: 37.825, longitude: -122.479),
    KMLCoordinate(latitude: 37.810, longitude: -122.477)
]

let line = KMLLineString(coordinates: coordinates)
```

### Polygon

Represents an enclosed area on the map, with optional cutouts inside it.

```swift
// A Polygon's LinearRing must contain at least four coordinates, with the first
// and last being equal.
let a = KMLCoordinate(latitude: 40.964, longitude: -109.031)
let b = KMLCoordinate(latitude: 37.005, longitude: -109.014)
let c = KMLCoordinate(latitude: 36.996, longitude: -102.030)
let d = KMLCoordinate(latitude: 40.916, longitude: -102.096)

let ring = try KMLPolygon.LinearRing(
    coordinates: [a, b, c, d, a]
)

let polygon = KMLPolygon(outerBoundary: ring)
```

### Multigeometry

Represents a group of other geometries connected together in the same placemark.

```swift
let multiGeometry = KMLMultiGeometry(
    geometries: [
        .point(point),
        .lineString(line),
        .polygon(polygon)
    ]
)
```

---

## Styles

### Color

`KMLColor` represents a color in KML’s **AABBGGRR** hex format and can convert to/from other color types:

```swift
let translucentRed = KMLColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
let hex = translucentRed.kmlString // "800000FF"

let swiftUIColor: Color = translucentRed.color
let uiColor: UIColor = translucentRed.uiColor
let nsColor: NSColor = translucentRed.nsColor
let cgColor: CGColor = translucentRed.cgColor
```

### Line and polygon styles

`KMLStyle` can be added to a Placemark for individual styling, or to a Document for shared styles.

```swift
let redLine = KMLLineStyle(
    width: 4.0,
    color: KMLColor(red: 1.0, green: 0.0, blue: 0.0)
)

let blueFill = KMLPolyStyle(
    isFilled: true,
    isOutlined: true,
    color: KMLColor(red: 0.0, green: 0.0, blue: 1.0)
)

let style = KMLStyle(
    id: "polygonStyle",
    lineStyle: redLine,
    polyStyle: blueFill
)

// Add the style to a KMLDocument's shared styles so it can be referenced by URL
let styledDocument = try KMLDocument(
    name: "Styled Document",
    features: [
        .placemark(
            KMLPlacemark(
                name: "Styled Placemark",
                featureDescription: "A polygon using a shared style.",
                geometry: .polygon(polygon),
                styleUrl: KMLStyleUrl(styleId: "polygonStyle")
            )
        )
    ],
    styles: [
        // shared styles must have non-nil ids
        .style(style)
    ]
)
```

---

## Further To-Do's

- **Partial KML support**: The library focuses on the KML elements most useful for map overlays and annotations. Not all KML features are implemented.
- **Polygon coordinate order**: Google's [KML Reference](https://developers.google.com/kml/documentation/kmlreference#polygon) states polygons' coordinates should be specified in counterclockwise order. This requirement is not implemented in **RCKML** yet.

If you need additional KML elements or helpers, please open an issue or PR.

---

## Dependencies

- [AEXML](https://github.com/tadija/AEXML) for reading and writing XML files
- [ZipFoundation](https://github.com/weichsel/ZIPFoundation) for dealing with compression for KMZ data.

---

## Contributing

- Issues and discussions: Please open issues for bugs, questions, or feature requests.
- Pull requests: PRs are welcome. Try to include tests for any new behavior and keep changes focused.

---

## License

This library is available under the terms of the **MIT license**. See the `LICENSE` file for details.
