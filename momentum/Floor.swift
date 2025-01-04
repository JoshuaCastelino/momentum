//
//  Floor.swift
//  momentum
//
//  Created by Josh on 01/01/2025.
//

import SpriteKit

class Floor: SKShapeNode {
    // Custom initializer for the floor
    convenience init(size: CGSize, position: CGPoint) {
        // Define the box frame
        let boxFrame = CGRect(origin: position, size: size)
        
        self.init(rect: boxFrame)
        self.strokeColor = .gray       // Box outline color
        self.lineWidth = 5            // Thickness of the box outline
        self.fillColor = .clear       // Keep the inside hollow
        self.zPosition = 1            // Ensure it's visible above the background

        // Add edge-based physics body to the box
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: boxFrame)
        self.physicsBody?.isDynamic = false // Floor is static
        self.physicsBody?.categoryBitMask = CollisionCategory.floor
        self.physicsBody?.collisionBitMask = CollisionCategory.player
        self.physicsBody?.contactTestBitMask = CollisionCategory.player
    }
}
