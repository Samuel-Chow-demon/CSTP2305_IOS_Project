//
//  GameObservableModel.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-17.
//

import Foundation

class GameViewModel {
    
    // singleton object
    static let obj = GameViewModel()
    
    // Hero Sprite Node
    var hero : HeroCharacter? = nil
    
    // Controller
    let controller = DragController()
    
    // Game Object Node
    var gameObjectList : [GameObject]
    
    // Store Active Contacts
    let colliderManager = ColliderManager()
    
    // prevent external init
    private init() {
        
        self.gameObjectList = []
    }
}
