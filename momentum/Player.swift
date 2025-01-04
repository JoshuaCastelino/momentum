//
//  Player.swift
//  momentum
//
//  Created by Josh on 01/01/2025.
//

import SpriteKit

class Player: SKShapeNode {
    // Custom initializer for the player
    convenience init(position: CGPoint, radius: CGFloat) {
        self.init(circleOfRadius: radius)
        self.fillColor = .white
        self.strokeColor = .white
        self.position = position
        self.zPosition = 1

        // Add physics body
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.isDynamic = true // Player is dynamic
        self.physicsBody?.mass = 1.0
        self.physicsBody?.categoryBitMask = CollisionCategory.player
        self.physicsBody?.collisionBitMask = CollisionCategory.floor
        self.physicsBody?.contactTestBitMask = CollisionCategory.floor
    }
}
