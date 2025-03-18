//
//  GameObject.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-17.
//

import Foundation
import SpriteKit

class GameObjectBase{
    
    var eObjectType : eGameObjType
    var worldCoordPoint : CGPoint = .zero
    
    var spriteNode: SKSpriteNode!
    var spriteTexture : SKTexture!
    var physicsBody: SKPhysicsBody!
    
    init(_ eObjType : eGameObjType,
         _ worldCoord: CGPoint)
    {
        eObjectType = eObjType
        worldCoordPoint = worldCoord
    }
}
