//
//  Game View.swift
//  Cell Sim
//
//  Created by Desire on 2026-08-19.
//

import SpriteKit
import SwiftUI
import AppKit

///An swift ui view wrapper for the skscene
struct GameView: View {
    
    var gameScene: GameScene

    var scene: SKScene {
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 1920, height: 1080)
        
        let scene = gameScene
        scene.size = .init(width: screenSize.width, height: screenSize.height)
       
        scene.scaleMode = .fill
        return scene
    }
    
    var body: some View {
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 1920, height: 1080)

        ZStack {
            SpriteView(scene: scene)
                .frame(width: screenSize.width, height: screenSize.height)
                .ignoresSafeArea()
        }
    }
    
    
}
