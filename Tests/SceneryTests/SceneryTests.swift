import XCTest
import SceneKit

@testable import Scenery

final class SceneryTests: XCTestCase {

    func testLogging() {

        sceneryLog.log("            SceneryTests| scenery logging test ..")

    }

    func testNodeAttach() {

        let node1 = SCNNode(name: "node1")
        let node2 = SCNNode(name: "node2")

        node1 <<< node2

        XCTAssertEqual(node1.childNodes.count, 1)

    }

    func testWholeScene() {

        let total = wholeScene()
        sceneryLog.log("            SceneryTests| scene = \(total) ..")

        let scene = total.rootNode
        XCTAssertEqual(scene.name, "scene")
        sceneryLog.log("            SceneryTests| \(scene.name!) -> \(scene.childNodes.map { $0.name }) ..")

        let frame = total.rootNode.childNodes[0]     // "frame"
        XCTAssertEqual(frame.name, "frame")
        sceneryLog.log("            SceneryTests|    \(frame.name!) -> \(frame.childNodes.map { $0.name }) ..")

        let earth = frame.childNodes[0]
        XCTAssertEqual(earth.name, "earth")
        sceneryLog.log("            SceneryTests|       \(earth.name!) -> \(earth.childNodes.map { $0.name }) ..")

        let globe = earth.childNodes[0]
        XCTAssertEqual(globe.name, "globe")
        sceneryLog.log("            SceneryTests|          \(globe.name!) -> \(globe.childNodes.map { $0.name }) ..")

        let obsvr = earth.childNodes[1]
        XCTAssertEqual(obsvr.name, "obsvr")
        sceneryLog.log("            SceneryTests|          \(obsvr.name!) -> \(obsvr.childNodes.map { $0.name }) ..")

        let solar = frame.childNodes[1]
        XCTAssertEqual(solar.name, "solar")
        sceneryLog.log("            SceneryTests|       \(solar.name!) -> \(solar.childNodes.map { $0.name }) ..")

        let orbit = frame.childNodes[2]
        XCTAssertEqual(orbit.name, "orbit")
        sceneryLog.log("            SceneryTests|       \(orbit.name!) -> \(orbit.childNodes.map { $0.name }) ..")

        let viewr = scene.childNodes[1]
        XCTAssertEqual(viewr.name, "viewr")
        sceneryLog.log("            SceneryTests|    \(viewr.name!) -> \(viewr.childNodes.map { $0.name }) ..")

        let camra = viewr.childNodes[0]
        XCTAssertEqual(camra.name, "camra")
        sceneryLog.log("            SceneryTests|       \(camra.name!) -> \(camra.childNodes.map { $0.name }) ..")

    }

}
