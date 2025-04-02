//
//  GameEnemyFactory.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-30.
//

import Foundation
import SpriteKit


class GameEnemyFactory
{
    var screenWidth : CGFloat = 0
    var screenHeight : CGFloat = 0
    var maxNumOfEnemy : UInt8
    var enemyObjectSize : CGFloat = 0
    var enemyMoveInterval : TimeInterval = 0.2 // default
    
    var lastSpawnEnemyTimeSec : TimeInterval = 0
    var nextSpawnEnemyInterval : TimeInterval = 0
    var spawnIntervalSecList : [TimeInterval] = [5] // default only per 5 sec
    
    let screenViewPort : GameScreenViewPort
    
    init(objectSize: CGFloat,
         moveInterval : TimeInterval,
         maxNumOfEnemy : UInt8, spawnIntervalSecList : [TimeInterval],
         screenViewPort : GameScreenViewPort)
    {
        let screenSize = getScreenSize()
        self.screenWidth = screenSize.width
        self.screenHeight = screenSize.height
        
        self.nextSpawnEnemyInterval = spawnIntervalSecList.randomElement()!
        
        self.maxNumOfEnemy = maxNumOfEnemy
        self.enemyObjectSize = objectSize
        self.enemyMoveInterval = moveInterval
        
        self.screenViewPort = screenViewPort
    }
    
    // pass the reference in
    private func SpwanEnemy(enemies : inout [EnemyCharacter],
                    eObjectType : eGameObjType,
                    addChild: (SKNode) -> Void)
    {
        if enemies.count >= Int(maxNumOfEnemy)
        {
            return
        }
        
        let spawnPositionOffsetBuffer = CGFloat(50)
        
        let currentScreenX = CGFloat(screenViewPort.screenWorldPoint.x)
        let currentScreenY = CGFloat(screenViewPort.screenWorldPoint.y)
        
        // right - 0 , left - 1, up - 2, down - 3
        let randomEdge = Int.random(in: 0..<4)
        var randomX = Int(currentScreenX)
        var randomY = Int(currentScreenY)
        
        switch(randomEdge)
        {
            case eDirection.eRIGHT.rawValue:
            
                let start = Int(currentScreenY - spawnPositionOffsetBuffer)
                let end = Int(currentScreenY + screenHeight + spawnPositionOffsetBuffer)
                randomX = Int(currentScreenX + screenWidth + spawnPositionOffsetBuffer)
                randomY = Int.random(in: start...end)
                
            case eDirection.eLEFT.rawValue:
            
                let start = Int(currentScreenY - spawnPositionOffsetBuffer)
                let end = Int(currentScreenY + screenHeight + spawnPositionOffsetBuffer)
                randomX = Int(currentScreenX - spawnPositionOffsetBuffer)
                randomY = Int.random(in: start...end)
                
            case eDirection.eUP.rawValue:
            
                let start = Int(currentScreenX - spawnPositionOffsetBuffer)
                let end = Int(currentScreenX + screenWidth + spawnPositionOffsetBuffer)
                randomY = Int(currentScreenY + screenHeight + spawnPositionOffsetBuffer)
                randomX = Int.random(in: start...end)
                
            case eDirection.eDOWN.rawValue:
            
                let start = Int(currentScreenX - spawnPositionOffsetBuffer)
                let end = Int(currentScreenX + screenWidth + spawnPositionOffsetBuffer)
                randomY = Int(currentScreenY - spawnPositionOffsetBuffer)
                randomX = Int.random(in: start...end)
            default:
                break
        }
        
        // able be attacked by player attack collider
        // no collision block
        let enemy = EnemyCharacter(eObjectType: eObjectType,
                                   speed: Constant.DEFAULT_ENEMY_SPEED,
                                   moveInterval : enemyMoveInterval, // 0.2 every 200 ms to move
                                   objectSize: enemyObjectSize,
                                   worldCoord: CGPoint(x: randomX, y: randomY), contactBitMask: PhysicsCategory.playerAttack, collisionBitMask: 0)
        
        enemies.append(enemy)
        addChild(enemy.spriteNode)
    }
    
    func checkAndSpawnEnemy(enemies : inout [EnemyCharacter],
                            eObjectType : eGameObjType,
                            addChild: (SKNode) -> Void,
                            accessNodeLock : NSLock)
    {
        let currentTime = CACurrentMediaTime()
        if (lastSpawnEnemyTimeSec == 0 ||
            currentTime - lastSpawnEnemyTimeSec >= nextSpawnEnemyInterval)
        {
            accessNodeLock.lock()
            SpwanEnemy(enemies : &enemies,
                        eObjectType : eObjectType,
                        addChild: addChild)
            accessNodeLock.unlock()
            
            nextSpawnEnemyInterval = spawnIntervalSecList.randomElement()!
            lastSpawnEnemyTimeSec = currentTime
        }
    }
}
