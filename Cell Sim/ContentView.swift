//
//  ContentView.swift
//  Cell Sim
//
//  Created by Desire on 2026-08-19.
//

import SwiftUI
import SwiftData
import AppKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(GameData.self) var gameData
    @State var gameScene: GameScene
  
    
    var body: some View {
        
        ZStack {
            GameView(gameScene: gameScene)
                .environment(gameData)
        }
        .onAppear {
            //- Forcing the screen to be full
            if let window = NSApp.windows.first {
                window.toggleFullScreen(nil)
            }
            
            
            NSApp.presentationOptions = [.hideDock]
        }
        
    }

    
}


