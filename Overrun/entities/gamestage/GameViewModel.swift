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
    
    // Controller
    var controller = DragController()
    
    // Game Object Node
    var gameObjectList : [GameObject]
    
    // prevent external init
    private init() {
        
        self.gameObjectList = []
    }
}
