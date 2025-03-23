//
//  GameObject.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-17.
//

import Foundation
import SpriteKit

// Interface child must implement
protocol GameObjectProtocal{
    func implementAddNodeToScene(_ addChild: (SKNode)-> Void)
}

class GameObjectBase : GameObjectProtocal{
    
    var eObjectType : eGameObjType
    var worldCoordPoint : CGPoint = .zero
    
    var spriteNode: SKSpriteNode!
    
    var spriteBeHarmOverlayNode: SKSpriteNode!
    var isUnderHarmInvincible : Bool = false
    var lastSufferHarmStartTime : TimeInterval = 0
    
    var spriteTexture : SKTexture!
    var physicsBody: SKPhysicsBody!
    
    init(_ eObjType : eGameObjType,
         _ worldCoord: CGPoint)
    {
        eObjectType = eObjType
        worldCoordPoint = worldCoord
    }
    
    func addNodeToScene(_ addChild: (SKNode)-> Void)
    {
        implementAddNodeToScene(addChild)
    }
    
    func implementAddNodeToScene(_ addChild: (SKNode) -> Void) {
        // default do nothing
    }
    
    func handleGetHarmOverlay()
    {
        // means start being harm
        if let isBeingHarm = spriteNode.userData?["harm"] as? Bool
        {
            if (isBeingHarm &&
                spriteBeHarmOverlayNode.alpha == 0 &&
                lastSufferHarmStartTime == 0)
            {
                spriteNode.userData!["harm"] = false
                spriteBeHarmOverlayNode.alpha = 0.8
                lastSufferHarmStartTime = CACurrentMediaTime()
            }
        }
        else if (spriteBeHarmOverlayNode.alpha < 0)
        {
            spriteBeHarmOverlayNode.alpha = 0
            lastSufferHarmStartTime = 0
        }
        else if (lastSufferHarmStartTime != 0)
        {
            let currentTime = CACurrentMediaTime()
            let timeDelta = currentTime - lastSufferHarmStartTime
            if (timeDelta > 0.06) // 60 ms
            {
                spriteBeHarmOverlayNode.alpha -= 0.3
            }
        }
    }
}
