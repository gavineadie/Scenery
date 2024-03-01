/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ OrbitConstruction.swift                                                                  Scenery ║
  ║ Created by Gavin Eadie on Feb01/24..    Copyright © 2024 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable statement_position

import SceneKit
import DemosKit
import SatelliteKit

let celestrakBase = "https://celestrak.org/NORAD/elements/gp.php?"
let elementsStore = ElementsStore(baseName: "com.ramsaycons.Sat")

let orbTickDelta = 30                                           // seconds between marks on orbit
let orbTickRange = -5*(60/orbTickDelta)...80*(60/orbTickDelta)  // range of marks on orbital track ..
let surTickRange = -5*(60/orbTickDelta)...300*(60/orbTickDelta) // range of marks on surface track ..

let horizonVertexCount = 90

let dotSatRadius = 75.0
let dotMaxRadius = 30.0
let dotMinRadius = 15.0

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┃
  ┃         → → OrbitView                                                                            ┃
  ┃                 moveOrbits(orbitNode)|                                                           ┃
  ┃         ------------------------------------------------------------ called every second         ┃
  ┃                     OrbitConstruction| OrbitNodes()                                              ┃
  ┃                     OrbitConstruction| no elements -- nil                                        ┃
  ┃                     TimelineView (1s)| moveOrbits() -- orbitNode.childNode.count = [0]           ┃
  ┃                     TimelineView (1s)| moveOrbits() --> elementsGroup == nil                     ┃
  ┃         elements not in cache, so get them                                                       ┃
  ┃              • Store.init| /Users/gavin/Library/Caches/com.ramsaycons.Sat                        ┃
  ┃              ×  Store.get| "visual" absent                                                       ┃
  ┃              •  Store.add| "visual" @ 2024-03-01 22:46:58 +0000                                  ┃
  ┃         ------------------------------------------------------------                             ┃
  ┃                     OrbitConstruction| OrbitNodes()                                              ┃
  ┃                     OrbitConstruction| no elements -- nil                                        ┃
  ┃                     TimelineView (1s)| moveOrbits() -- orbitNode.childNode.count = [0]           ┃
  ┃                     TimelineView (1s)| moveOrbits() --> elementsGroup == nil                     ┃
  ┃         elements now available                                                                   ┃
  ┃              •  Store.get| "visual"                                                              ┃
  ┃         ------------------------------------------------------------                             ┃
  ┃                     OrbitConstruction| OrbitNodes()                                              ┃
  ┃                     OrbitConstruction| orbit <<< H-25544 + O-25544 +                             ┃
  ┃                     TimelineView (1s)| moveOrbits() -- orbitNode.childNode.count = [2]           ┃
  ┃                     TimelineView (1s)| moveOrbits() --> sat# 25544                               ┃
  ┃                   extension Satellite| everySecond()                                             ┃
  ┃                   extension Satellite| 'O-25544' [171]                                           ┃
  ┃                   extension Satellite| 'H-25544' [91]                                            ┃
  ┃         ------------------------------------------------------------                             ┃
  ┃                     TimelineView (1s)| moveOrbits() -- orbitNode.childNode.count = [2]           ┃
  ┃                     TimelineView (1s)| moveOrbits() --> sat# 25544                               ┃
  ┃                   extension Satellite| everySecond()                                             ┃
  ┃                   extension Satellite| 'O-25544' [171]                                           ┃
  ┃                   extension Satellite| 'H-25544' [91]                                            ┃
  ┃         ------------------------------------------------------------                             ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ for the satellite(s) we want to display ..                                                       ┃
  ┃         .. create STATIC dots for the orbit "O-", groundtrack "S-" and horizon "H-" ..           ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

public func makeOrbitNodes(orbitNode: SCNNode) -> SCNNode {
    if Debug.scene { print("       OrbitConstruction| makeOrbitNodes()") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                              +--------------------------------------------------------------+    ┆
  ┆                              |                        +-- Node("orbit") --+                 |    ┆
  ┆                              |                        |                   +-- Node("H-nnn") |    ┆
  ┆                              |                        |                   +-- Node("O-nnn") |    ┆
  ┆                              |                        |                   +-- Node("S-nnn") |    ┆
  ┆                              +------------------------|-------------------------------------+    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
//    let orbitNode = // SCNNode(name: "orbit")

    if let elements = elementsGroup?.table[25544] {  // 42684
        let satellite = Satellite(elements: elements)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ create (don't position) a SCNNode with a trail of dots along the satellite's orbit ..            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let hTicksNode = SCNNode(name: "H-" + satellite.noradIdent)

        for _ in 0...horizonVertexCount {
            let dottyGeom = SCNSphere(radius: dotMaxRadius)         //
            dottyGeom.isGeodesic = true
            dottyGeom.segmentCount = 4
            dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1) // NSColor.white (!!CPU!!)
            dottyGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            hTicksNode <<< SCNNode(geometry: dottyGeom)
        }

        orbitNode <<< hTicksNode

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ create (don't position) a SCNNode with a trail of dots along the satellite's orbit ..            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let oTicksNode = SCNNode(name: "O-" + satellite.noradIdent)

        for _ in orbTickRange {
            let dottyGeom = SCNSphere(radius: dotMaxRadius)         //
            dottyGeom.isGeodesic = true
            dottyGeom.segmentCount = 4
            dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1) // NSColor.white (!!CPU!!)
            dottyGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            oTicksNode <<< SCNNode(geometry: dottyGeom)
        }

        orbitNode <<< oTicksNode

        if Debug.scene {
            if orbitNode.childNodes.count > 0 {
                var nodeNames = ""
                for node in orbitNode.childNodes {
                    nodeNames += "\(node.name!) + "
                }
                if Debug.scene { print("       OrbitConstruction| \(orbitNode.name!) <<< \(nodeNames.dropLast())") }
            } else {
                if Debug.scene { print("       OrbitConstruction| \(orbitNode.name!) childCount = 0") }
            }
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ create (don't position) a SCNNode with a trail of dots along the satellite's groundtrack ..      ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let sTicksNode = SCNNode(name: "S-" + satellite.noradIdent)

        for _ in surTickRange {
            let dottyGeom = SCNSphere(radius: dotMaxRadius)
            dottyGeom.isGeodesic = true
            dottyGeom.segmentCount = 4
            dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)    // (!!CPU!!)
            dottyGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            sTicksNode <<< SCNNode(geometry: dottyGeom)
        }

//      orbitNode <<< sTicksNode            // FIXME: find a better way to condition display

//      satellite.everySecond(orbitNode: orbitNode)
    } else {
        if Debug.scene { print("       OrbitConstruction| no elements -- \(elementsGroup?.prettyPrint())") }
    }

    return orbitNode
}


/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func loadGroup(_ groupKey: String) -> ElementsGroup? {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ make a URL to get the JSON file from Celestrak, and validate it ..                               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    guard let visualJsonURL = URL(
        string: "\(celestrakBase)GROUP=\(groupKey)&FORMAT=json")
                                            else { fatalError("celestrak.org URL malformed ..") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ prepare the JSON decoder .. time format is "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"                        ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Micros)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ if the elements store contains the required data, use it ..                                      ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    if let jsonString = elementsStore.extractElements(groupKey: groupKey) {

        let elementsArray = try! decoder.decode([Elements].self,
                                                from: jsonString.data(using: .utf8)!)
        return ElementsGroup(elementsArray)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ else, use the URL to get the JSON file and install it in the elements store ..                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    } else {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ set a task in process to get the JSON file from the server ..                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        Task {
            let jsonString = await fetchFrom(url: visualJsonURL)
            elementsStore.insertElements(groupKey: groupKey, cacheText: jsonString)

            let elementsArray = try! decoder.decode([Elements].self,
                                                    from: jsonString.data(using: .utf8)!)
            return ElementsGroup(elementsArray)
        }
        
    }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ if the element store was empty AND we are waiting for the network to get it ..                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    return nil
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func fetchFrom(url: URL) async -> String {
    if url.isFileURL { fatalError("fetchFrom: doesn't do files ..") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ request data from the server's URL, and get data and response ..                                 ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    do {
        let (data, response) = try await URLSession.shared.data(from: url)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ if the server response is not "200" -- fail ..                                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print(String(decoding: data, as: UTF8.self))
            fatalError("fetchFrom :non-200 net response ..")
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ if the data recieved from the server is UTF8 (ASCII) -- fail ..                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        guard let string = String(data: data,
                                  encoding: .utf8) else { fatalError("fetchFrom: data error ..") }
        return string
    } catch { fatalError("fetchFrom \(error.localizedDescription) ..") }
}

