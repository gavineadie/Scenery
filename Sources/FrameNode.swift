/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ FrameNode.swift                                                                          Scenary ║
  ║ Created by Gavin Eadie on Feb12/24      Copyright © 2024 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import SatelliteKit
import SceneKit

let USE_SCENE_FILE = false

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ contruct the "frame" node .. this is the 'interial frame' of the universe ..                     │
  │      rotate -90° about Y to bring +X to "front" then rotate -90° about X to bring +Z to "up"     │
  │                                                             .. and attach it to the "scene" node │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func makeFrameNode() -> SCNNode {
    if Debug.scene { print("       SceneConstruction| makeFrame()") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                                 Node("frame") --------+                                          ┆
  ┆                                                       |                                          ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let frameNode = SCNNode(name: "frame")              	    // frameNode
    frameNode.eulerAngles = SCNVector3(-Float.π/2.0,
                                       -Float.π/2.0, 
                                        0.0)                    // "X" forward; "Z" up

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ try and get the base node of the "earth" scene from the file model ..                            ┆
  ┆                                                              .. if it fails, programmatically .. ┆
  ┆ contruct the "earth" node .. this is the sphere of the Earth plus anything that rotates with it. ┆
  ┆ The Earth is not exactly spherical; that oblateness, is gained by scaling the "earth" node.      ┆
  ┆                                                               .. rotate to earth to time of day. ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    var earthNode: SCNNode
    if USE_SCENE_FILE {
        earthNode = SCNScene(named: "com.ramsaycons.earth.scn")?
                                                .rootNode.childNodes.first ?? makeEarthNode()
    } else {
        earthNode = makeEarthNode()                             // earthNode ("globe", "grids", coast")
    }

    if let globeNode = earthNode.childNode(withName: "globe", recursively: true) {
        let globeMaterial = SCNMaterial()
        globeMaterial.lightingModel = .physicallyBased

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
        globeMaterial.roughness.contents = UIColor.lightGray
        globeMaterial.diffuse.contents = UIImage(named: "earth_diffuse_4k")
#else
        globeMaterial.roughness.contents = NSColor.lightGray
        globeMaterial.diffuse.contents = NSImage(named: "earth_diffuse_4k")
#endif

        globeNode.geometry?.materials = [globeMaterial]
    }

    earthNode.scale = SCNVector3(1.0, 1.0, 6356.752/6378.135)   // oblate squish

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                                                               .. rotate to earth to time of day. ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    rotateEarth(earthNode)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                                 Node("frame") --------+                                          ┆
  ┆                                                       +-- Node("earth") --                       ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    frameNode <<< earthNode                                     //           "frame" << "earth"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ .. and attach "solar" (with 1 "light" child to provide illumination) node to "frame"             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let solarNode = makeSolarLight()                            // solarNode ("solar", "light")
    solarNode.childNodes[0].constraints = [SCNLookAtConstraint(target: earthNode)]

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                                 Node("frame") --------+   Node("earth")                          ┆
  ┆                                                       +-- Node("solar" <<< "light")              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    frameNode <<< solarNode                                     //           "frame" << "solar"

    if Debug.scene { earthNode <<< addMarker(color: #colorLiteral(red: 0.95, green: 0.85, blue: 0.55, alpha: 1), at: VectorFloat(7500.0, 0.0, 0.0)) }

    return frameNode
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                                                               .. rotate to earth to time of day. ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
public func rotateEarth(_ earthNode: SCNNode) {
#if os(iOS) || os(tvOS) || os(watchOS)  || os(visionOS)
    earthNode.eulerAngles.z = Float(zeroMeanSiderealTime(julianDate: julianDaysNow()) * deg2rad)
#else
    earthNode.eulerAngles.z = CGFloat(zeroMeanSiderealTime(julianDate: julianDaysNow()) * deg2rad)
#endif
}
