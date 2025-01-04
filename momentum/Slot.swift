//
//  slot.swift
//  momentum
//
//  Created by Josh on 04/01/2025.
//

import SpriteKit


class GappedLineNode: SKShapeNode {
    
    init(totalHeight: CGFloat, gapStart: CGFloat, gapHeight: CGFloat) {
        super.init()

        // Validate gap parameters
        let gapEnd = gapStart + gapHeight
        guard totalHeight > 0, gapStart >= 0, gapEnd <= totalHeight else {
            fatalError("Invalid gap parameters: Gap must fit within the total height.")
        }

        // Create a path for the vertical line
        let path = CGMutablePath()
        
        // Bottom segment of the line
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: gapStart))
        
        // Top segment of the line
        path.move(to: CGPoint(x: 0, y: gapEnd))
        path.addLine(to: CGPoint(x: 0, y: totalHeight))
        
        // Assign the path to the SKShapeNode
        self.path = path
        self.strokeColor = .white
        self.lineWidth = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
