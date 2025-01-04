//
//  GameScene.swift
//  momentum
//
//  Created by Josh on 01/01/2025.
//

import SpriteKit
import GameplayKit

struct CollisionCategory {
    static let player: UInt32 = 0x1 << 0
    static let floor: UInt32 = 0x1 << 1
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var startLocation : CGPoint?
    private var player: Player?

    private let touchIconRadius: CGFloat = 10
    private var startTouchIcon: SKShapeNode!
    private var pathNode : SKShapeNode = SKShapeNode()
    
    
    func calculateForce(startLocation: CGPoint, endLocation: CGPoint) -> CGVector{
        let deltaX = endLocation.x - startLocation.x
        let deltaY = endLocation.y - startLocation.y
        let distance = CGFloat(hypot(deltaX, deltaY))
        let angle = atan2(deltaY, deltaX)
        
        let forceMultiplier: CGFloat = 6
        let angleToApply = angle + .pi
        let forceToApply = distance * forceMultiplier
        
        let dx = forceToApply * cos(angleToApply) // Horizontal force
        let dy = forceToApply * sin(angleToApply) // Vertical force
        let normalisedForceVector = normalizeForce(forceX: dx, forceY: dy, maxForce: 900)
        return normalisedForceVector
    }
    
    func normalizeForce(forceX: CGFloat, forceY: CGFloat, maxForce: CGFloat) -> CGVector {
        // Calculate the magnitude of the force vector
        let magnitude = hypot(forceX, forceY)

        // If the magnitude exceeds maxForce, normalize and scale the vector
        if magnitude > maxForce {
            let normalizedX = forceX / magnitude
            let normalizedY = forceY / magnitude
            return CGVector(dx: normalizedX * maxForce, dy: normalizedY * maxForce)
        }

        // If the magnitude is within limits, return the original vector
        return CGVector(dx: forceX, dy: forceY)
    }
    
    fileprivate func addStartTouchIcon(_ touchStartLocation: CGPoint) {
        startLocation = touchStartLocation
        startTouchIcon = SKShapeNode(circleOfRadius: touchIconRadius)
        startTouchIcon.position = touchStartLocation
        startTouchIcon.fillColor = SKColor.clear
        self.addChild(startTouchIcon)
    }
    
    fileprivate func updateDragPath(_ currentTouchLocation: CGPoint) {
        if pathNode.parent == nil{
            let path = CGMutablePath()
            path.move(to: startLocation!)
            path.addLine(to: currentTouchLocation)
            pathNode.path = path
            self.addChild(pathNode)
        }
        else{
            self.removeChildren(in: [pathNode])
        }
    }
    
    override func didMove(to view: SKView) {
        // Physics stuff
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
        
        // Player sprite
        self.player = Player(position: CGPoint(x: self.size.width / 2, y: self.size.height / 2), radius: 20)
        self.addChild(player!)
        
        // Initialise the floor
        let floor = Floor(size: CGSize(width: self.size.width, height: self.size.height), position: CGPoint(x: 0, y: 0))
        self.addChild(floor)
        
        pathNode.strokeColor = SKColor.yellow
        pathNode.lineWidth = 2
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Logic for when two physics bodies make contact
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // may want to allow more than 1 touch in the future
        if touches.count > 1 { return }
        
        else{
            // Set the start location of the touch
            let touchStartLocation = touches.first!.location(in: self)
            addStartTouchIcon(touchStartLocation)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let currentTouchLocation = touches.first!.location(in: self)
        updateDragPath(currentTouchLocation)

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeChildren(in: [startTouchIcon, pathNode])
        let endLocation = touches.first!.location(in: self)
        let forceVector = calculateForce(startLocation: startLocation!, endLocation: endLocation)
        print(forceVector)
        player!.physicsBody?.applyImpulse(forceVector)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
