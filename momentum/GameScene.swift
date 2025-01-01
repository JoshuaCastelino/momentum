//
//  GameScene.swift
//  momentum
//
//  Created by Josh on 01/01/2025.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        // Player sprite
        let circle = SKShapeNode(circleOfRadius: 50)
        circle.fillColor = .white
        circle.strokeColor = .white
        circle.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        circle.zPosition = 1
        
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        circle.physicsBody?.isDynamic = true
        circle.physicsBody?.categoryBitMask = 0x1 << 0
        circle.physicsBody?.collisionBitMask = 0x1 << 1
        circle.physicsBody?.contactTestBitMask = 0x1 << 1


        self.addChild(circle)

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Logic for when two physics bodies make contact
        print("Contact detected between \(contact.bodyA) and \(contact.bodyB)")
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
