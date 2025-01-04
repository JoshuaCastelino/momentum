//
//  Floor.swift
//  momentum
//
//  Created by Josh on 01/01/2025.
//

import SpriteKit
import SpriteKit

class Floor: SKShapeNode {
    // Custom initializer for the floor
    convenience init(size: CGSize, position: CGPoint) {
        self.init()

        // Create the rectangle shape
        let rectPath = CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size)
        self.path = CGPath(rect: rectPath, transform: nil)

        self.strokeColor = .gray
        self.lineWidth = 2
        self.fillColor = .brown
        self.zPosition = 1

        // Add a solid physics body to the rectangle
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true // Floor is static
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = CollisionCategory.floor
        self.physicsBody?.collisionBitMask = CollisionCategory.player
        self.physicsBody?.contactTestBitMask = CollisionCategory.player
        self.physicsBody?.affectedByGravity = false

        // Set position
        self.position = position
    }
}
