/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SceneConstruction.swift                                                                  Scenery ║
  ║ Created by Gavin Eadie on Mar12/17   Copyright © 2017-24 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable identifier_name

import MetalKit
import SceneKit
import SatelliteKit

let Rₑ: Double = 6378.135                // equatorial radius (polar radius = 6356.752 Kms)

enum Debug {
    static let scene = false
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃                                                                                                  ┃
  ┃  .. gets the rootNode (sceneNode = "scene") in the sceneView and attaches various other nodes:   ┃
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
  ┃                         |    |                        |                   +-- Node("globe") |    ┃
  ┃                         |    |                        |                   +-- Node("grids") |    ┃
  ┃                         |    |                        |                   +-- Node("coast") |    ┃
  ┃                         |    +------------------------|-------------------------------------+    ┃
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
  ┃         → → OrbitView                                                                            ┃
  ┃                 SceneConstruction| wholeScene()                                                  ┃
  ┃         ------------------------------------------------------------ called once                 ┃
  ┃                     SceneConstruction| makeFrame()                                               ┃
  ┃                         SceneConstruction| makeEarth()                                           ┃
  ┃                             SceneConstruction| makeGlobe()                                       ┃
  ┃                             SceneConstruction| geometry(from: grids)                             ┃
  ┃                             SceneConstruction| geometry(from: coast)                             ┃
  ┃                             SceneConstruction| makeObserver()                                    ┃
  ┃                         SceneConstruction| makeSolarLight()                                      ┃
  ┃                         SceneConstruction| addMarkerSpot()                                       ┃
  ┃                                                                                                  ┃
  ┃                     SceneConstruction| makeViewrNode()                                           ┃
  ┃                         SceneConstruction| addMarkerSpot()                                       ┃
  ┃                         SceneConstruction| addMarkerSpot()                                       ┃
  ┃                         SceneConstruction| addMarkerSpot()                                       ┃
  ┃                         SceneConstruction| makeCameraNode()                                      ┃
  ┃                                                                                                  ┃
  ┃                     OrbitConstruction| makeOrbitNodes()                                          ┃
  ┃         ------------------------------------------------------------                             ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

// MARK: - Scene construction functions ..

public func wholeScene() -> SCNScene {
    if Debug.scene { print("       SceneConstruction| wholeScene()") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ contruct an empty scene ..                                                                       ┆
  ┆                                                                                                  ┆
  ┆╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┆
  ┆                                                                                                  ┆
  ┆ SCNView.scene.rootNode                                                                           ┆
  ┆     == Node("scene") ---+----                                                                    ┆
  ┆                         |                                                                        ┆
  ┆                         |                                                                        ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let scene = SCNScene()                                      // make an empty scene ..
    
	let sceneNode = scene.rootNode                              // get its root node ..
    sceneNode.name = "scene"                                    // .. and name it ..

    do {
        let textureLoader = MTKTextureLoader(device: MTLCreateSystemDefaultDevice()!)
        scene.background.contents = try textureLoader.newTexture(name: "Star1024", scaleFactor: 1.0,
                                                                 bundle: .main, options: nil)
    } catch {
        print("Texture Loader error: \(error.localizedDescription)")
    }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ contruct the "frame" node .. this is the 'interial frame' of the universe ..                     ┆
  ┆      rotate -90° about Y to bring +X to "front" then rotate -90° about X to bring +Z to "up"     ┆
  ┆                                                             .. and attach it to the "scene" node ┆
  ┆                                                                                                  ┆
  ┆╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌┆
  ┆                                                                                                  ┆
  ┆                              +--------------------------------------------------------------+    ┆
  ┆                              |                                                              |    ┆
  ┆                              |  Node("frame") --------+                                     |    ┆
  ┆                              |                        +-- Node("earth") --+                 |    ┆
  ┆                              |                        |                   +-- Node("globe") |    ┆
  ┆                              |                        |                   +-- Node("grids") |    ┆
  ┆                              |                        |                   +-- Node("coast") |    ┆
  ┆                              +------------------------|-------------------------------------+    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let frameNode = makeFrameNode()
    sceneNode <<< frameNode

    sceneNode <<< makeViewrNode()

    if let camraNode = sceneNode.childNode(withName: "camra", recursively: true) {
        let cameraConstraint = SCNLookAtConstraint(target: frameNode)
        cameraConstraint.isGimbalLockEnabled = true
        camraNode.constraints = [cameraConstraint]
    }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                              +--------------------------------------------------------------+    ┆
  ┆                              |                                                              |    ┆
  ┆                              |  Node("frame") --------+                                     |    ┆
  ┆                              |                        +-- Node("orbit") --+                 |    ┆
  ┆                              +------------------------|-------------------------------------+    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    frameNode <<< SCNNode(name: "orbit")        // where we will attach satellite nodes

    return scene
}
