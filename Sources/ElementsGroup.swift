/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ElementsGroup.swift                                                                     DemosKit ║
  ║ Created by Gavin Eadie on Apr20/17 ... Copyright 2017-24 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// Note: 2022-08-02 using "visual" group .. timing is weird !
//
//    Test Case '-[DemosKitTests.DemosKitTests testTLEs]' passed (4.195 seconds).
//    Test Case '-[DemosKitTests.DemosKitTests testJSON]' passed (2.472 seconds).
//    Test Case '-[DemosKitTests.DemosKitTests testXMLs]' passed (8.711 seconds).

//    Test Case '-[DemosKitTests.DemosKitTests testTLEs]' passed (0.683 seconds).
//    Test Case '-[DemosKitTests.DemosKitTests testJSON]' passed (10.282 seconds).
//    Test Case '-[DemosKitTests.DemosKitTests testXMLs]' passed (4.037 seconds).


import Foundation
import SatelliteKit


/// An in-memory structure, an ElementsGroup is a Dictionary of processed Elements indexed
/// by the object's numeric NORAD ID, plus an optional Date property which represents the age of
/// the ElementsGroup ..
/// ```
///  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
///  ┃   +------------------------------------------------+   ┃
///  ┃   |  group: "visual", etc ..                       |   ┃
///  ┃   |  dated: "last-mod"                             |   ┃
///  ┃   |  state:                                        |   ┃
///  ┃   +-----------------------+------------------------+   ┃
///  ┃   |           | +--------------------------------+ |   ┃
///  ┃   | 12345 --> | | commonName, noradIndex,        | |   ┃
///  ┃   |           | | launchName, t₀, e₀, i₀, ω₀,    | |   ┃
///  ┃   |           | | Ω₀, M₀, n₀, a₀, ephemType,     | |   ┃
///  ┃   |           | | tleClass, tleNumber, revNumber | |   ┃
///  ┃   |           | +--------------------------------+ |   ┃
///  ┃   +-----------------------+------------------------+   ┃
///  ┃   |           | +--------------------------------+ |   ┃
///  ┃   | 43210 --> | | Elements ...                   | |   ┃
///  ┃   |           | |                                | |   ┃
///  ┃   |           | +--------------------------------+ |   ┃
///  ┃   +-----------------------+------------------------+   ┃
///  ┃   |           |                                    |   ┃
///  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
/// ```
/// One ElementsGroup would typically be derived from one set/file of satellite TLEs 
/// ("stations", "visual", etc).
public struct ElementsGroup: Codable {

    var group: String
    var dated: Date = Date.distantPast
    var state: String                            // code for .. something?
    public var table = [UInt : Elements]()

    public init() {
        self.group = "NONE"
        if #available(macOS 12, iOS 15, *) {
            self.dated = Date.now
        } else {
            self.dated = Date()
        }
        self.state = "INIT"
    }

    public init(_ elementsArray: [Elements]) {
        self.init()
        self.table = Dictionary(uniqueKeysWithValues: elementsArray.map{ (UInt($0.noradIndex), $0) })
        self.state = "INIT-ARRAY"
    }

    /// Initialize the `ElementsGroup` from a string of TLEs, typically the contents of TLE file.
    /// - Parameter elementsText: a string of TLEs
    public init(_ elementsText: String) {
        do {
            self.init(try preProcessTLEs(elementsText).map { try Elements($0.0, $0.1, $0.2) })
            self.state = "INIT-STRING"
        } catch {
            fatalError("ElementsGroup(folded TLE text) failed")
        }
    }

    public func norad(_ norad: UInt) -> Elements? { table[norad] }

}

@available(macOS 12.0, tvOS 15.0, *)
public extension ElementsGroup {

/// ```
///  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
///  ┃  functions of ElementsGroup which populate the 'table' ┃
///  ┃      downloadTLEs: from link to a TLE text file ..     ┃
///  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
/// ```
    mutating func downloadTLEs(from tlesLink: String, for groupName: String, usingCache: Bool = true) async {
        guard let url = URL(string: tlesLink) else { return }
        
        do {
            let elementsStream = await fetchFrom(url: url)
            let elementsArray = try preProcessTLEs(elementsStream).map { try Elements($0.0, $0.1, $0.2) }

            self = ElementsGroup(elementsArray)
            self.group = groupName
            if #available(iOS 15, *) {
                self.dated = Date.now
            } else {
                self.dated = Date()
            }
            self.state = "TLEs LOADED"                      // code for .. something?
        } catch {

        }
    }


/// ```
///  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
///  ┃  functions of ElementsGroup which populate the 'table' ┃
///  ┃      downloadJSON: from link to a JSON text file ..    ┃
///  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
/// ```
/// download a JSON file of satellite elements (JSON derived elements are NOT cached)
/// - Parameters:
///   - jsonLink: the URL where the satellite JSON TLEs will be found
///   - group: the name of the `ElementsGroup`
    mutating func downloadJSON(from jsonLink: String, for groupName: String, usingCache: Bool = false) async {
        guard let url = URL(string: jsonLink) else { return }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                                                             .. go to the network │
  │ Note: macOS 12 (Swift 5.5) gives us async/await ..                                               │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Micros)

        do {
            let elementsJSON = await fetchFrom(url: url).data(using: .utf8)!
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ now, deal with the returned JSON data ..                                                         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let elementsArray = try decoder.decode([Elements].self, from: elementsJSON)

            self = ElementsGroup(elementsArray)
            self.group = groupName
            if #available(iOS 15, *) {
                self.dated = Date.now
            } else {
                self.dated = Date()
            }
            self.state = "JSON LOADED"                      // code for .. something?
        } catch {
            print(error)
        }

    }

/// ```
///  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
///  ┃  functions of ElementsGroup which populate the 'table' ┃
///  ┃      downloadXMLs: from link to a XML text file ..     ┃
///  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
/// ```
/// download a XML file of satellite elements
/// - Parameters:
///   - xmlLink: the URL where the satellite XML TLEs will be found
///   - group: the name of the `ElementsGroup`
    mutating func downloadXMLs(from xmlLink: String, for groupName: String) async {
        guard let url = URL(string: xmlLink) else { return }

        let elementsXML = await fetchFrom(url: url)
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ divide the XML string into an array of strings: "<segment>...</segment>" ..                      ┆
  ┆         .. 1) spilt at "</body>" to get strings ending "</segment>"                              ┆
  ┆         .. 2) spilt at "<body>" to get strings starting "<segment>"                              ┆
  ┆                 (gives two strings .. throw away the first one leaving "<segment>...</segment>"  ┆
  ┆                                                                                                  ┆
  ┆     "<segment>                                                                                   ┆
  ┆         <metadata>                                                                               ┆
  ┆             <OBJECT_NAME>THOR AGENA D R/B</OBJECT_NAME>                                          ┆
  ┆             <OBJECT_ID>1964-002A</OBJECT_ID>                                                     ┆
  ┆             <CENTER_NAME>EARTH</CENTER_NAME>                                                     ┆
  ┆             <REF_FRAME>TEME</REF_FRAME>                                                          ┆
  ┆             <TIME_SYSTEM>UTC</TIME_SYSTEM>                                                       ┆
  ┆             <MEAN_ELEMENT_THEORY>SGP4</MEAN_ELEMENT_THEORY>                                      ┆
  ┆         </metadata>                                                                              ┆
  ┆         <data>                                                                                   ┆
  ┆             <meanElements>                                                                       ┆
  ┆                 <EPOCH>2023-11-12T11:55:41.193120</EPOCH>                                        ┆
  ┆                 <MEAN_MOTION>14.32956936</MEAN_MOTION>                                           ┆
  ┆                 <ECCENTRICITY>.0032906</ECCENTRICITY>                                            ┆
  ┆                 <INCLINATION>99.0437</INCLINATION>                                               ┆
  ┆                 <RA_OF_ASC_NODE>271.0086</RA_OF_ASC_NODE>                                        ┆
  ┆                 <ARG_OF_PERICENTER>206.5810</ARG_OF_PERICENTER>                                  ┆
  ┆                 <MEAN_ANOMALY>153.3687</MEAN_ANOMALY>                                            ┆
  ┆             </meanElements>                                                                      ┆
  ┆             <tleParameters>                                                                      ┆
  ┆                 <EPHEMERIS_TYPE>0</EPHEMERIS_TYPE>                                               ┆
  ┆                 <CLASSIFICATION_TYPE>U</CLASSIFICATION_TYPE>                                     ┆
  ┆                 <NORAD_CAT_ID>733</NORAD_CAT_ID>                                                 ┆
  ┆                 <ELEMENT_SET_NO>999</ELEMENT_SET_NO>                                             ┆
  ┆                 <REV_AT_EPOCH>11677</REV_AT_EPOCH>                                               ┆
  ┆                 <BSTAR>.19664E-3</BSTAR>                                                         ┆
  ┆                 <MEAN_MOTION_DOT>.493E-5</MEAN_MOTION_DOT>                                       ┆
  ┆                 <MEAN_MOTION_DDOT>0</MEAN_MOTION_DDOT>                                           ┆
  ┆             </tleParameters>                                                                     ┆
  ┆         </data>                                                                                  ┆
  ┆     </segment>"                                                                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        var stringArray = elementsXML.components(separatedBy: "</body>")     //
        stringArray = stringArray.map { $0.components(separatedBy: "<body>").last! }
        let elementsArray = stringArray.dropLast().map { Elements(xmlData: $0.data(using: .utf8)!) }

        self = ElementsGroup(elementsArray)
        self.group = groupName
if #available(iOS 15, *) {
            self.dated = Date.now
        } else {
            self.dated = Date()
        }
        self.state = "XML LOADED"                      // code for .. something?

        //        groups.updateValue(ElementsGroup(elementsArray), forKey: groupName)
    }

    enum APIError: Error {
        case invalidUrl
        case invalidData
    }

/// get the string contents of a network URL (not a file URL)
/// - Parameter url: the URL where the satellite TLEs will be found
/// - Returns: the name of the `ElementsGroup`
    func fetchFrom(url: URL) async -> String {

        if url.isFileURL { fatalError("fetchFrom: doesn't do files ..") }

        do {

            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print(String(decoding: data, as: UTF8.self))
                fatalError("fetchFrom :non-200 net response ..")
            }

            guard let string = String(data: data,
                                      encoding: .utf8) else { fatalError("fetchFrom: data error ..") }
            return string

        } catch {
            print(error)
            fatalError("fetchFrom error ..")
        }

    }

}

//MARK: - Pretty Printer

public extension ElementsGroup {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func prettyPrint() -> String {

        String(format: """

            ┌─[ElementsGroup]───────────────────────────────────────────────────────
            │  group: "\(group)"
            │  dated: \(dated)
            │  state: "\(state)"
            │  count: \(table.count)
            └───────────────────────────────────────────────────────────────────────
            """)
    }
}
