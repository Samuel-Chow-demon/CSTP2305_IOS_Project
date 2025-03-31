//
//  EnemyCharacter.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-30.
//

import Foundation
import SpriteKit

class EnemyCharacter : CharacterBase{
    
    var moveInterval: TimeInterval = 0.050 // 50 ms default
    var lastMoveUpdateTime: TimeInterval = 0
    
    init(eObjectType : eGameObjType,
         speed : CGFloat,
         moveInterval: TimeInterval,
         objectSize: CGFloat, worldCoord : CGPoint,
        contactBitMask : UInt32, collisionBitMask : UInt32)
    {
        super.init(eObjectType,
                   Constant.DEFAULT_ENEMY_HEALTH, speed,
                   objectSize, worldCoord,
                   contactBitMask, collisionBitMask)
        
        // Remind that all the spriteNode default anchor point is (0.5, 0.5) -> the center of the sprite
        // default not apply the position
        spriteNode.position = .zero
        
        spriteNode.isHidden = false
        spriteNode.zPosition = 90
        
        self.moveInterval = moveInterval
        
        // Current Enemy not yet have attack sprite node
        //setupAttackSpriteNode(attackSpritePredix : spriteName)
    }
    
    func MoveTowardsHero(viewport : GameScreenViewPort, heroPos : CGPoint)
    {
        let xDiff = heroPos.x - self.worldCoordPoint.x
        let yDiff = heroPos.y - self.worldCoordPoint.y
        
        let angleInRad = atan2(yDiff, xDiff)
        
        let deltaX = cos(angleInRad) * objectSpeed
        let deltaY = sin(angleInRad) * objectSpeed
        
        let currentTime = CACurrentMediaTime()
        if (lastMoveUpdateTime == 0 ||
            currentTime - lastMoveUpdateTime >= moveInterval)
        {
            Move(viewport : viewport,
                 delta: CGPoint(x: deltaX, y: deltaY))
            lastMoveUpdateTime = currentTime
        }
        updateTextureForDirection(angleInRad)
    }
}
