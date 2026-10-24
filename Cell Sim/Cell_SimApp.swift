//
//  Cell_SimApp.swift
//  Cell Sim
//
//  Created by Desire on 2026-08-19.
//

import SwiftUI
import SwiftData

@main
struct Cell_SimApp: App {
   
    @State var gameData: GameData = GameData()

    
    
    var body: some Scene {
        WindowGroup {
            ContentView(gameScene: GameScene(gameData: gameData))
                .environment(gameData)
        }
     
    }
}
