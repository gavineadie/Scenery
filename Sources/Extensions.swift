/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Extensions.swift                                                                         Scenery ║
  ║ Created by Gavin Eadie on Feb12/24      Copyright © 2024 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import SatelliteKit
import SceneKit

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │                               G E N E R I C S    N E E D E D                                     │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
public struct VectorFloat {
    var x: Float
    var y: Float
    var z: Float

    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = Float(x)
        self.y = Float(y)
        self.z = Float(z)
    }
    public init(_ v: VectorFloat) { x = v.x; y = v.y; z = v.z }
}

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) 
public struct VertexFloat {
    var x: Float
    var y: Float
    var z: Float

    public init(_ x: Float, _ y: Float, _ z: Float) { self.x = x; self.y = y; self.z = z }
    public init(_ v: VertexFloat) { x = v.x; y = v.y; z = v.z }
}
#else
public struct VertexFloat {
    var x: CGFloat
    var y: CGFloat
    var z: CGFloat

    public init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) { self.x = x; self.y = y; self.z = z }
    public init(_ v: VertexFloat) { self.x = v.x; self.y = v.y; self.z = v.z }
}
#endif

extension SCNVector3 {

#if os(iOS) || os(tvOS) || os(watchOS)  || os(visionOS)
    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.init(x: Float(x), y: Float(y), z: Float(z))
    }

    public init(_ v: Vector) {
        self.init(x: Float(v.x), y: Float(v.y),z: Float(v.z))
    }

    public init(_ v: VectorFloat) {
        self.init(x: Float(v.x), y: Float(v.y),z: Float(v.z))
    }
    #else
    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.init(x: x, y: y,z: z)
    }

    public init(_ v: Vector) {
        self.init(x: v.x, y: v.y,z: v.z)
    }

    public init(_ v: VectorFloat) {
        self.init(x: CGFloat(v.x), y: CGFloat(v.y),z: CGFloat(v.z))
    }
    #endif
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
infix operator <<<

extension SCNNode {

    public convenience init(name: String) {
        self.init()
        self.name = name
    }

    public convenience init(geometry: SCNGeometry?, name: String) {
        self.init(geometry: geometry)
        self.name = name
    }

    static func <<< (lhs: SCNNode, rhs: SCNNode) {
        lhs.addChildNode(rhs)
    }

}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ define π (pi) .. the ration between the diameter and circumference of a circle ..                │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
extension Double {
    static let π: Double = 3.141_592_653_589_793_238_462_643_383_279_502_884_197_169_399_375_105
}

extension CGFloat {
    static let π: CGFloat = 3.141_592_653_589_793_238_463
}

extension Float {
    static let π: Float = 3.141_592_653_589_793_238_463
}

