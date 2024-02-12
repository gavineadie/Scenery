/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Geometry.swift                                                                           Scenary ║
  ║ Created by Gavin Eadie on Feb12/24      Copyright © 2024 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import SceneKit

let vertexStride = MemoryLayout<VertexFloat>.stride

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ reads a binary file (x,y,z),(x,y,z), (x,y,z),(x,y,z), .. and makes a SceneKit Geometry ..        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func geometry(from vertexAssetName: String) -> SCNGeometry? {
    if Debug.scene { print("       SceneConstruction| geometry(from: \(vertexAssetName)") }

//    let assetURL = Bundle.module.url(forResource: vertexAssetName, withExtension: "vector")!
//    let vertexData = try! Data(contentsOf: assetURL)

    if #available(OSX 10.11, *) {
		let vertexAsset = NSDataAsset(name: vertexAssetName)
		guard let vertexData = vertexAsset?.data else {
			print("vertex file '\(vertexAssetName)' missing")
			return nil
		}
	
		let vertexSource = SCNGeometrySource(data: vertexData,
											 semantic: SCNGeometrySource.Semantic.vertex,
											 vectorCount: vertexData.count/(vertexStride*2),
											 usesFloatComponents: true, componentsPerVector: 3,
											 bytesPerComponent: MemoryLayout<Float>.size,
											 dataOffset: 0, dataStride: vertexStride)
	
		let element = SCNGeometryElement(data: nil, primitiveType: .line,
										 primitiveCount: vertexData.count/(vertexStride*2),
										 bytesPerIndex: MemoryLayout<UInt16>.size)
	
		return SCNGeometry(sources: [vertexSource], elements: [element])
    } else {
        return nil
    }
}
