/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SceneConstruction.swift                                                                  Scenary ║
  ║ Created by Gavin Eadie on Mar12/17   Copyright © 2017-24 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable identifier_name

import MetalKit
import SceneKit
import SatelliteKit

let USE_SCENE_FILE = false
let Rₑ: Double = 6378.135                // equatorial radius (polar radius = 6356.752 Kms)

enum Debug {
    static let scene = true
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃                                                                                                  ┃
  ┃  .. gets the rootNode (sceneNode = "scene") and attaches various other nodes:                    ┃
  ┃                                                                                                  ┃
  ┃     "frame" represents the inertial frame and it is transformed to orient +Z "up".               ┃
  ┃                                                                                                  ┃
  ┃         It contains the "earth" node which is composed of a solid sphere ("globe"), graticule    ┃
  ┃         marks ("grids"), and the geographic coastlines, lakes , rivers, etc ("coast").           ┃
  ┃                                                                                                  ┃
  ┃                              +--------------------------------------------------------------+    ┃
  ┃ SCNView.scene.rootNode       |                                                              |    ┃
  ┃     == Node("scene") ---+----|  Node("frame") --------+                                     |    ┃
  ┃                         |    |                        |                                     |    ┃
  ┃                         |    |                        +-- Node("earth") --+                 |    ┃
  ┃                              |                        |                   +-- Node("globe") |    ┃
  ┃                              |                        |                   +-- Node("grids") |    ┃
  ┃                              |                        |                   +-- Node("coast") |    ┃
  ┃                              +------------------------|-------------------------------------+    ┃
  ┃                                                                                                  ┃
  ┃             "construct(scene:)" adds nodes programmatically to represent other objects. It adds  ┃
  ┃             the light of the sun ("solar"), rotating once a year in the inertial coordinates of  ┃
  ┃             the "frame", and the observer station ("obsvr") to the "earth".                      ┃
  ┃                                                                                                  ┃
  ┃             "construct(scene:)" also adds a 'double node' to represent to external viewer; a     ┃
  ┃             node ("viewr"), with a camera ("camra") at a fixed distant radius pointing to the    ┃
  ┃             the frame center.                                                                    ┃
  ┃                                                       |                   |                      ┃
  ┃                         |                             |                   |                      ┃
  ┃                         |                             |   (Optional)      |                      ┃
  ┃                         |                             +-- Node("spots")   +-- Node("obsvr")      ┃
  ┃                         |                             |                                          ┃
  ┃                         |                             +-- Node("solar" <<< "light")              ┃
  ┃                         |                                                                        ┃
  ┃                         +-- Node("viewr" <<< "camra")                                            ┃
  ┃                                                                                                  ┃
  ┃         Satellites also moving in the inertial frame but they are not added here ..              ┃
  ┃                                                                                                  ┃
  ┃╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┃
  ┃          SceneConstruction| >> orbitScene()                                                      ┃
  ┃          SceneConstruction| makeFrame()                                                          ┃
  ┃          SceneConstruction| makeEarth()                                                          ┃
  ┃          SceneConstruction| makeGlobe()                                                          ┃
  ┃          SceneConstruction| geometry(from: grids                                                 ┃
  ┃          SceneConstruction| geometry(from: coast                                                 ┃
  ┃          SceneConstruction| makeObserver()                                                       ┃
  ┃          SceneConstruction| makeSolarLight()                                                     ┃
  ┃          SceneConstruction| addMarkerSpot()                                                      ┃
  ┃          SceneConstruction| makeCameraView()                                                     ┃
  ┃          SceneConstruction| addMarkerSpot()                                                      ┃
  ┃          SceneConstruction| addMarkerSpot()                                                      ┃
  ┃          SceneConstruction| addMarkerSpot()                                                      ┃
  ┃          SceneConstruction| makeCameraNode()                                                     ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

public func wholeScene() -> SCNScene {
    if Debug.scene { print("       SceneConstruction| >> wholeScene()") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ SCNView.scene.rootNode                                                                           ┆
  ┆     == Node("scene") ---+----                                                                    ┆
  ┆                         |                                                                        ┆
  ┆                         |                                                                        ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let scene = SCNScene()                                      // make an empty scene ..
    
	let sceneNode = scene.rootNode                              // get its root node ..
    sceneNode.name = "scene"                                    // .. and name it ..

    do {
        let textureLoader = MTKTextureLoader(device: MTLCreateSystemDefaultDevice()!) // sceneView.device!)
        scene.background.contents = try textureLoader.newTexture(name: "Star1024", scaleFactor: 1.0,
                                                                 bundle: .main, options: nil)
    } catch {
        print("Texture Loader error: \(error.localizedDescription)")
    }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                              +--------------------------------------------------------------+    ┆
  ┆                              |                                                              |    ┆
  ┆                              |  Node("frame") --------+                                     |    ┆
  ┆                              |                        |                                     |    ┆
  ┆                              |                        +-- Node("earth") --+                 |    ┆
  ┆                              |                        |                   +-- Node("globe") |    ┆
  ┆                              |                        |                   +-- Node("grids") |    ┆
  ┆                              |                        |                   +-- Node("coast") |    ┆
  ┆                              +------------------------|-------------------------------------+    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let frameNode = makeFrame()
    sceneNode <<< frameNode

    sceneNode <<< makeViewrNode()

    if let camraNode = sceneNode.childNode(withName: "camra", recursively: true) {
        let cameraConstraint = SCNLookAtConstraint(target: frameNode)
        cameraConstraint.isGimbalLockEnabled = true
        camraNode.constraints = [cameraConstraint]
    }

    return scene
}
