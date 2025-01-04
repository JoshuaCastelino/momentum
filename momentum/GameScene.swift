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
    private var touchStartLocation: CGPoint?
    private var player: Player?

    private let touchIconRadius: CGFloat = 10
    private var startTouchIcon: SKShapeNode!
    private var pathNode: SKShapeNode = SKShapeNode()
    
    private var floorStartPosition: CGPoint?
    private var floor: SKShapeNode?
    private var floorWidth: CGFloat?
    private let floorHeight: CGFloat = 100
    private var floorDimensions: CGSize?
    private var floors: [Floor] = []
    private var floorColours: [SKColor] = [.red, .blue, .green]
    private var floorRotationIndex = 0
    
    private var startHeight: CGFloat = 10
    
    func calculateForce(_ endLocation: CGPoint) -> CGVector {
        guard let touchStartLocation else { return .zero }
        
        let deltaX = endLocation.x - touchStartLocation.x
        let deltaY = endLocation.y - touchStartLocation.y
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
    
    func addStartTouchIcon(_ cameraNode: SKNode) {
        guard let touchStartLocation else { return }
        
        startTouchIcon = SKShapeNode(circleOfRadius: touchIconRadius)
        startTouchIcon.position = touchStartLocation
        startTouchIcon.fillColor = SKColor.clear
        cameraNode.addChild(startTouchIcon)
    }
    
    func updateDragPath(_ currentTouchLocation: CGPoint, _ cameraNode: SKNode) {
        guard let touchStartLocation else { return }
        
        if pathNode.parent == nil {
            let path = CGMutablePath()
            path.move(to: touchStartLocation)
            path.addLine(to: currentTouchLocation)
            pathNode.path = path
            cameraNode.addChild(pathNode)
        } else {
            cameraNode.removeChildren(in: [pathNode])
        }
    }
    
    func cameraSmoothing() {
        guard let camera = self.camera else { return }

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
    
    func initialiseFloor() {
        guard let floorWidth else { return }
        guard let floorDimensions else { return }
        
        let floorStartPosition = CGPoint(x: floorWidth / 2, y: startHeight)
        for i in 0...2 {
            
            let curFloorPosition = CGPoint(
                x: floorStartPosition.x + (floorWidth * CGFloat(i)),
                y: floorStartPosition.y
            )
            
            let curFloor = Floor(size: floorDimensions, position: curFloorPosition, colour: floorColours[i])
            floors.append(curFloor)
            self.addChild(curFloor)
        }
    }
    
    func updateFloorPositions() {
        guard let player = self.player else { return }
        guard let floorWidth = self.floorWidth else { return }
        guard let floorDimensions = self.floorDimensions else { return }
        
        let firstFloor = floors[0]
        let middleFloor = floors[1]
        let finalFloor = floors[2]
        
        if player.position.x >= middleFloor.position.x + floorWidth / 3 {
            floorRotationIndex += 1
            let newXPosition: CGFloat = finalFloor.position.x + floorWidth
            let newPosition = CGPoint(x: newXPosition, y: finalFloor.position.y)
            let newColour = floorColours[floorRotationIndex % 3]
            firstFloor.position = newPosition
                    
            floors[0] = middleFloor
            floors[1] = finalFloor
            floors[2] = firstFloor
        }
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
        
        // Floor setup
        floorWidth = self.size.width
        floorDimensions = CGSize(width: floorWidth!, height: floorHeight)

        initialiseFloor()
        
        pathNode.strokeColor = SKColor.yellow
        pathNode.lineWidth = 2
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Logic for when two physics bodies make contact
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // may want to allow more than 1 touch in the future
        if touches.count > 1 { return }
        if let cameraNode = camera {
            touchStartLocation = touches.first!.location(in: cameraNode)
            addStartTouchIcon(cameraNode)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 1 { return }
        if let cameraNode = camera {
            let currentTouchLocation = touches.first!.location(in: cameraNode)
            updateDragPath(currentTouchLocation, cameraNode)
        }


    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 1 { return }

        self.removeChildren(in: [startTouchIcon, pathNode])
        if let cameraNode = camera {
            let endLocation = touches.first!.location(in: cameraNode)
            let forceVector = calculateForce(endLocation)
            player!.physicsBody?.applyImpulse(forceVector)
            cameraNode.removeChildren(in: [pathNode, startTouchIcon])
        }

    }
        
    override func update(_ currentTime: TimeInterval) {
        cameraSmoothing()
        updateFloorPositions()
    }
}
