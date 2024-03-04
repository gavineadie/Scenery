/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ OrbitConstruction.swift                                                                  Scenery ║
  ║ Created by Gavin Eadie on Feb01/24..    Copyright © 2024 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import SceneKit
import DemosKit
import SatelliteKit

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
  ┃                     TimelineView (1s)| moveOrbits() -- elementsGroup == nil                      ┃
  ┃         elements not in cache, so get them                                                       ┃
  ┃              • Store.init| /Users/gavin/Library/Caches/com.ramsaycons.Sat                        ┃
  ┃              ×  Store.get| "visual" absent                                                       ┃
  ┃              •  Store.add| "visual" @ 2024-03-01 22:46:58 +0000                                  ┃
  ┃         ------------------------------------------------------------                             ┃
  ┃                     OrbitConstruction| OrbitNodes()                                              ┃
  ┃                     OrbitConstruction| no elements -- nil                                        ┃
  ┃                     TimelineView (1s)| moveOrbits() -- orbitNode.childNode.count = [0]           ┃
  ┃                     TimelineView (1s)| moveOrbits() -- elementsGroup == nil                      ┃
  ┃         elements now available                                                                   ┃
  ┃              •  Store.get| "visual"                                                              ┃
  ┃         ------------------------------------------------------------                             ┃
  ┃                     OrbitConstruction| OrbitNodes()                                              ┃
  ┃                     OrbitConstruction| orbit <<< H-25544 + O-25544 +                             ┃
  ┃                     TimelineView (1s)| moveOrbits() -- orbitNode.childNode.count = [2]           ┃
  ┃                     TimelineView (1s)| moveOrbits() -- sat# 25544                                ┃
  ┃                   extension Satellite| everySecond()                                             ┃
  ┃                   extension Satellite| 'O-25544' [171]                                           ┃
  ┃                   extension Satellite| 'H-25544' [91]                                            ┃
  ┃         ------------------------------------------------------------                             ┃
  ┃                     TimelineView (1s)| moveOrbits() -- orbitNode.childNode.count = [2]           ┃
  ┃                     TimelineView (1s)| moveOrbits() -- sat# 25544                                ┃
  ┃                   extension Satellite| everySecond()                                             ┃
  ┃                   extension Satellite| 'O-25544' [171]                                           ┃
  ┃                   extension Satellite| 'H-25544' [91]                                            ┃
  ┃         ------------------------------------------------------------                             ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ for the satellite(s) we want to display ..                                                       ┃
  ┃         .. create STATIC dots for the orbit "O-", groundtrack "S-" and horizon "H-" ..           ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

public func makeOrbitNodes(orbitNode: SCNNode) {
    sceneryLog.log("       OrbitConstruction| makeOrbitNodes()")

    if let elements = elementsGroup?.table[25544] {  // 42684
        let satellite = Satellite(elements: elements)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ create (don't position) a SCNNode with a trail of dots along the satellite's orbit ..            ┆
  ┆                                                                                                  ┆
  ┆╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┆
  ┆                              +--------------------------------------------------------------+    ┆
  ┆                              |                        +-- Node("orbit") --+                 |    ┆
  ┆                              |                        |                   +-- Node("H-nnn") |    ┆
  ┆                              +------------------------|-------------------------------------+    ┆
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
  ┆                                                                                                  ┆
  ┆╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┆
  ┆                              +--------------------------------------------------------------+    ┆
  ┆                              |                        +-- Node("orbit") --+                 |    ┆
  ┆                              |                        |                   +-- Node("O-nnn") |    ┆
  ┆                              +------------------------|-------------------------------------+    ┆
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
                sceneryLog.log("       OrbitConstruction| \(orbitNode.name!) <<< \(nodeNames.dropLast(3))")
            } else {
                sceneryLog.log("       OrbitConstruction| \(orbitNode.name!) childCount = 0")
            }
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ create (don't position) a SCNNode with a trail of dots along the satellite's groundtrack ..      ┆
  ┆                                                                                                  ┆
  ┆╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┆
  ┆                              +--------------------------------------------------------------+    ┆
  ┆                              |                        +-- Node("orbit") --+                 |    ┆
  ┆                              |                        |                   +-- Node("S-nnn") |    ┆
  ┆                              +------------------------|-------------------------------------+    ┆
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
    }
}
