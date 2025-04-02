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
    
    // Enemies List
    var enemies : [EnemyCharacter] = []
    var enemyFactory : GameEnemyFactory? = nil
    
    // Controller
    let controller = DragController()
    
    // Game Object Node
    var gameObjectList : [GameObject]
    
    // Store Active Contacts
    let colliderManager = ColliderManager()
    
    // Metrics Display
    var healthDisplay : HealthDisplay? = nil
    var enemyNumDisplay : EnemyNumDisplay? = nil
    var popupBox : PopupGameWinLoseBox? = nil
    
    func cleanUp() {
        hero?.spriteNode.removeFromParent()
        hero = nil
        
        for enemy in enemies {
            enemy.spriteNode.removeFromParent()
        }
        enemies.removeAll()
        
        enemyFactory = nil
        
        colliderManager.clearAll()
        
        for obj in gameObjectList {
            obj.spriteNode.removeFromParent()
        }
        gameObjectList.removeAll()
        
        // Remove UI elements
        healthDisplay?.healthDisplayNode.removeFromParent()
        healthDisplay = nil
        
        enemyNumDisplay?.enemyNumDisplayNode.removeFromParent()
        enemyNumDisplay = nil
        
        popupBox?.popupNode.removeFromParent()
        popupBox = nil
    }
    
    // prevent external init
    private init() {
        
        self.gameObjectList = []
    }
}
