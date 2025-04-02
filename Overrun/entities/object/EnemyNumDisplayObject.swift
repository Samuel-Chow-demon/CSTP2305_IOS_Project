//
//  EnemyNumDisplayObject.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-04-01.
//

import Foundation
import SpriteKit

class EnemyNumDisplay {
    
    var enemyNumDisplayNode : SKSpriteNode!
    var enemyDisplayObj : GameFixedObject!
    var enemySizeLabel : SKLabelNode!
    var enemySize = Int()
    
    let spacing = CGFloat(5.0)
    
    init(initEnemySize: Int,
         objectSize: CGFloat,
         fixedCoord: CGPoint,
         zPosition : CGFloat = 100)    // always on top
    {
        let numberOfDigit = CGFloat(initEnemySize / 10) + CGFloat(1)
        let width = objectSize + numberOfDigit * objectSize / 2 + (numberOfDigit - 1) * spacing * 10
        enemyNumDisplayNode = SKSpriteNode(color: .clear, size: CGSize(width: width, height: objectSize))
        enemyNumDisplayNode.position = fixedCoord
        enemyNumDisplayNode.zPosition = zPosition
        
        enemyDisplayObj = GameFixedObject(spriteName: "??",
                                          objectSize: CGSize(width: objectSize, height: objectSize),
                                          fixedCoord : CGPoint(x: 0, y: 0))
        
        enemyDisplayObj.spriteNode?.color = .gray
        enemyDisplayObj.spriteNode?.colorBlendFactor = 0.5
        enemyDisplayObj.spriteNode?.alpha = 1

        enemyNumDisplayNode.addChild(enemyDisplayObj.spriteNode!)
        
        let crossLabel = SKLabelNode(text: "X")
        crossLabel.name = "crossLabel"
        crossLabel.fontName = "Arial Rounded MT Bold"
        crossLabel.fontSize = 25
        crossLabel.fontColor = UIColor(hex: 0x234f5c, alpha: 1)
        crossLabel.position = CGPoint(x: enemyDisplayObj.spriteNode?.size.width ?? 0 + spacing * 3, y: -10)
        enemyNumDisplayNode.addChild(crossLabel)
        
        enemySize = initEnemySize
        
        enemySizeLabel = SKLabelNode(text: "\(initEnemySize)")
        enemySizeLabel.name = "enemySize"
        enemySizeLabel.fontName = "Arial Rounded MT Bold"
        enemySizeLabel.fontSize = 36
        enemySizeLabel.fontColor = UIColor(hex: 0x234f5c, alpha: 1)
        enemySizeLabel.position = CGPoint(x: crossLabel.position.x + spacing * 7, y: -12)
        enemyNumDisplayNode.addChild(enemySizeLabel)
    }
    
    func updateEnemySize(enemyTexture : SKTexture,
                         decrement : Int)
    {
        enemySize -= decrement
        enemyDisplayObj.spriteNode?.texture = enemyTexture
        enemySizeLabel.text = "\(enemySize)"
    }
}
