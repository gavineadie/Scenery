/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Geometry.swift                                                                           Scenery ║
  ║ Created by Gavin Eadie on Feb12/24      Copyright © 2024 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import SceneKit

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ reads a binary file (x,y,z),(x,y,z), (x,y,z),(x,y,z), .. and makes a SceneKit Geometry ..        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func geometry(from vertexAssetName: String) -> SCNGeometry? {
    sceneryLog.log("       SceneConstruction| geometry(from: \(vertexAssetName))")

    let vertexAsset = NSDataAsset(name: vertexAssetName)

    guard let vertexData = vertexAsset?.data else {
        sceneryLog.error("vertex file '\(vertexAssetName)' missing")
        return nil
    }

    let vertexStride = MemoryLayout<Float>.stride * 3
    let vertexCount = (vertexData.count) / (vertexStride*2)         // count of vertices (two per line)

    let vertexSource = SCNGeometrySource(data: vertexData,
                                         semantic: SCNGeometrySource.Semantic.vertex,
                                         vectorCount: vertexCount,
                                         usesFloatComponents: true,
                                         componentsPerVector: 3,
                                         bytesPerComponent: MemoryLayout<Float>.size,
                                         dataOffset: 0, 
                                         dataStride: vertexStride)

    let element = SCNGeometryElement(data: nil, 
                                     primitiveType: .line,
                                     primitiveCount: vertexCount,
                                     bytesPerIndex: MemoryLayout<Int>.size)

    return SCNGeometry(sources: [vertexSource], elements: [element])
}
