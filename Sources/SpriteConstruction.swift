/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SpriteConstruction.swift                                                              Geometries ║
  ║ Created by Gavin Eadie on Jul21/17   Copyright © 2017-24 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import SpriteKit

extension SKNode {

    public convenience init(named name: String) {
        self.init()
        self.name = name
    }

    static func <<< (lhs: SKNode, rhs: SKNode) {
        lhs.addChild(rhs)
    }

}

public func makeSpriteScene() -> SKScene {

    let overlay = SKScene(size: CGSize(width: 600, height: 600))
    overlay.backgroundColor = .clear

    let baseNode = SKNode(named: "BASE")
    overlay <<< baseNode

    let cred = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
    cred.fontSize = 12.0
    cred.position = CGPoint(x: 300, y: 580)
    cred.name = "CRED"
    cred.text = "XXX" // Geometries.version
    baseNode <<< cred

    let rectNodeA = SKSpriteNode(color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), size: CGSize(width: 80, height: 80))
    rectNodeA.position = CGPoint(x: 50, y: 50)
    rectNodeA.name = "BotL"
    overlay <<< rectNodeA

    let rectNodeB = SKSpriteNode(color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), size: CGSize(width: 80, height: 80))
    rectNodeB.position = CGPoint(x: 550, y: 50)
    rectNodeB.name = "BotR"
    overlay <<< rectNodeB

    let rectNodeC = SKSpriteNode(color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), size: CGSize(width: 80, height: 80))
    rectNodeC.position = CGPoint(x: 50, y: 550)
    rectNodeC.name = "TopL"
    overlay <<< rectNodeC

    let rectNodeD = SKSpriteNode(color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), size: CGSize(width: 80, height: 80))
    rectNodeD.position = CGPoint(x: 550, y: 550)
    rectNodeD.name = "TopR"
    overlay <<< rectNodeD

    let word = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
    word.position = CGPoint(x: 300, y: 10)
    word.name = "WORD"
    word.text = "Geometry Tests"
    baseNode <<< word

    return overlay
}
