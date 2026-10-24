//
//  Game Scene.swift
//  Cell Sim
//
//  Created by Desire on 2026-08-19.
//

import SwiftUI
import SpriteKit
import Observation

enum PhysicsCategory: UInt32 {
    case cell = 0b1
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameData: GameData
    var cameraNode: SKCameraNode!
    
    init(gameData: GameData) {
        self.gameData = gameData
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 1920, height: 1080)
        
        super.init(size: screenSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: .zero)
        
        cameraNode = SKCameraNode()
        addChild(cameraNode)
        self.camera = cameraNode
        
        // Spawn standard and intelligent cells
        for i in 0..<100 {
            let isIntelligent = (i % 2 == 0) // 50% intelligent cells
            let color: SKColor = isIntelligent ? .green : .red
            let newCell = Cell(color: color, radius: 10, intelligent: isIntelligent)
            
            newCell.physicsBody = SKPhysicsBody(circleOfRadius: 10)
            newCell.physicsBody?.categoryBitMask = PhysicsCategory.cell.rawValue
            newCell.physicsBody?.collisionBitMask = PhysicsCategory.cell.rawValue
            newCell.physicsBody?.affectedByGravity = false
            newCell.physicsBody?.isDynamic = true
            
            gameData.cells.append(newCell)
            
            addChild(newCell)
            newCell.position = .init(x: CGFloat.random(in: 0...1000), y: CGFloat.random(in: 0...1000))
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        guard let camera = cameraNode else { return }
        
        let zoomFactor = event.deltaY * 10.0
        let newScale = camera.xScale - zoomFactor
        
        let minZoom: CGFloat = 0.2
        let maxZoom: CGFloat = 1000.0
        
        let clampedScale = max(minZoom, min(maxZoom, newScale))
        camera.xScale = clampedScale
        camera.yScale = clampedScale
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let intersection = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if intersection == (PhysicsCategory.cell).rawValue {
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for cell in gameData.cells {
            cell.exist(cells: gameData.cells, sceneSize: size)
        }
    }
}
