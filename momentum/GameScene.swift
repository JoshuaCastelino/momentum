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
    
    private var label: SKLabelNode?
    private var spinnyNode: SKShapeNode?
    private var startLocation: CGPoint?
    private var player: Player?

    private let touchIconRadius: CGFloat = 10
    private var startTouchIcon: SKShapeNode!
    private var pathNode: SKShapeNode = SKShapeNode()
    
    private var floorStartPosition: CGPoint?
    private var floor: SKShapeNode?
    private var floors: [Floor] = []
    
    private var startHeight: CGFloat = 10
    
    func calculateForce(startLocation: CGPoint, endLocation: CGPoint) -> CGVector {
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
        if pathNode.parent == nil {
            let path = CGMutablePath()
            path.move(to: startLocation!)
            path.addLine(to: currentTouchLocation)
            pathNode.path = path
            self.addChild(pathNode)
        } else {
            self.removeChildren(in: [pathNode])
        }
    }
    
    fileprivate func cameraSmoothing(_ camera: SKCameraNode) {
        // Define the smoothing factor (0.1 = slow, 1.0 = instant)
        let smoothingFactor: CGFloat = 0.1
        // Interpolate the camera's position towards the player's position
        let targetPosition = player!.position
        let currentPosition = camera.position
        let newPosition = CGPoint(
            x: currentPosition.x + (targetPosition.x - currentPosition.x) * smoothingFactor,
            y: currentPosition.y + (targetPosition.y - currentPosition.y) * smoothingFactor
        )
        // Update the camera's position
        camera.position = newPosition
    }
    
    override func didMove(to view: SKView) {
        // Physics setup
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
        
        // Camera setup
        let cameraNode = SKCameraNode()
        let minY: CGFloat = self.size.height / 2
        let maxY: CGFloat = 0
        
        self.camera = cameraNode
        self.addChild(cameraNode)
        
        // Create the y constraint
        let yConstraint = SKConstraint.positionY(SKRange(lowerLimit: minY, upperLimit: maxY))
        cameraNode.constraints = [yConstraint]
        
        // Player sprite
        self.player = Player(position: CGPoint(x: self.size.width / 2, y: startHeight + 20), radius: 20)
        self.addChild(player!)
        
        // Initialise the floor
        let floorWidth = self.size.width
        let floorHeight: CGFloat = 5
        let floorDimensions = CGSize(width: floorWidth, height: floorHeight)
        let floorStartPosition = CGPoint(x: floorWidth / 2, y: startHeight)
        let floor = Floor(size: floorDimensions, position: floorStartPosition)

        for i in 1...3 {
            let curFloorPosition = CGPoint(
                x: floorStartPosition.x + (floorWidth * CGFloat(i)),
                y: floorStartPosition.y
            )
            let curFloor = Floor(size: floorDimensions, position: curFloorPosition)
            floors.append(curFloor)
            self.addChild(curFloor)
        }
        
        self.addChild(floor)
        
        pathNode.strokeColor = SKColor.yellow
        pathNode.lineWidth = 2
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Logic for when two physics bodies make contact
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // may want to allow more than 1 touch in the future
        if touches.count > 1 { return } else {
            // Set the start location of the touch
            let touchStartLocation = touches.first!.location(in: self)
            addStartTouchIcon(touchStartLocation)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 1 { return }

        let currentTouchLocation = touches.first!.location(in: self)
        updateDragPath(currentTouchLocation)

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 1 { return }

        self.removeChildren(in: [startTouchIcon, pathNode])
        let endLocation = touches.first!.location(in: self)
        let forceVector = calculateForce(startLocation: startLocation!, endLocation: endLocation)
        print(forceVector)
        player!.physicsBody?.applyImpulse(forceVector)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let camera = self.camera else { return }

        cameraSmoothing(camera)
    }
}
