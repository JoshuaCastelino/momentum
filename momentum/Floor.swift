//
//  Floor.swift
//  momentum
//
//  Created by Josh on 01/01/2025.
//

import SpriteKit
class Floor: SKShapeNode {
    
    // Custom initializer for the floor
    convenience init(size: CGSize, position: CGPoint, colour: SKColor) {
        self.init()

        // Create the rectangle shape
        let rectPath = CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size)
        self.path = CGPath(rect: rectPath, transform: nil)

        self.strokeColor = .gray
        self.fillColor = colour
        self.zPosition = 1

        // Add a solid physics body to the rectangle
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = CollisionCategory.floor
        self.physicsBody?.collisionBitMask = CollisionCategory.player
        self.physicsBody?.contactTestBitMask = CollisionCategory.player

        // Set position
        self.position = position
    }
    
}
