//
//  HealthDisplayObject.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-04-01.
//

import Foundation
import SpriteKit

class HealthDisplay{
    
    var healthDisplayNode : SKSpriteNode!
    var healthNodeList : [GameFixedObject] = []
    var healthObjectSize : CGFloat!
    var healthSpriteName : String!
    
    let spacing = CGFloat(10.0)
    
    init(spriteName: String,
          initHealth : Int,
          objectSize: CGFloat,
          fixedCoord : CGPoint,
          zPosition : CGFloat = 100)    // always on top
    {
        healthObjectSize = objectSize
        healthSpriteName = spriteName
        
        let width = CGFloat(initHealth) * objectSize + (CGFloat(initHealth) - 1) * spacing
        healthDisplayNode = SKSpriteNode(color: .clear, size: CGSize(width: width, height: objectSize))
        healthDisplayNode.position = fixedCoord
        healthDisplayNode.zPosition = zPosition
        
        for i in 0..<initHealth{
            let position = CGPoint(x: CGFloat(i) * (objectSize + spacing), y: 0)
            let healthNodeObject = GameFixedObject(spriteName: spriteName,
                                             objectSize: objectSize,
                                             fixedCoord : position)
            
            healthNodeObject.spriteNode?.alpha = 0.7
            healthNodeList.append(healthNodeObject)
            healthDisplayNode.addChild(healthNodeObject.spriteNode!)
        }
    }
    
    func decrementHealth()
    {
        if !healthNodeList.isEmpty
        {
            let lastHealthNode = healthNodeList.removeLast()
            lastHealthNode.spriteNode?.removeFromParent()
        }
    }
    
    func incrementHealth()
    {
        let currentSize = healthNodeList.count
        let position = CGPoint(x: CGFloat(currentSize - 1) * (healthObjectSize + spacing), y: 0)
        let healthNodeObject = GameFixedObject(spriteName: healthSpriteName,
                                                 objectSize: healthObjectSize,
                                                 fixedCoord : position)
        healthNodeObject.spriteNode?.alpha = 0.7
        healthNodeList.append(healthNodeObject)
        healthDisplayNode.addChild(healthNodeObject.spriteNode!)
    }
}
