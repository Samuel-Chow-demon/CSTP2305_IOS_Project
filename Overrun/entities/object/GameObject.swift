//
//  GameObject.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-17.
//

import Foundation
import SpriteKit

class GameObject : GameObjectBase{
    
    
    init(texture: SKTexture, objType: eGameObjType,
          objectSize: CGFloat,
          worldRowCol : CGPoint,
          needBody: Bool = true, zPosition : CGFloat = 0,
          contactBitMask : UInt32 = 0, collisionBitMask : UInt32 = 0)
    {
        let worldCoord = CGPoint(x: CGFloat(worldRowCol.x) * objectSize + objectSize / 2,
                                   y: CGFloat(worldRowCol.y) * objectSize + objectSize / 2 + Constant.BACKGROUND_BOTTOM_OFFSET)
        super.init(objType, worldCoord)
        
        spriteTexture = texture
        spriteNode = SKSpriteNode(texture: spriteTexture)
        spriteNode.name = needBody ? Constant.SPRITE_NODE_COLLIDABLE : Constant.SPRITE_NODE_COLLIDABLE
        spriteNode.userData = NSMutableDictionary()
        spriteNode.userData!["id"] = "\(objType.rawValue)_\(worldCoord.x)_\(worldCoord.y)"
        
        spriteNode.size = CGSize(width: objectSize, height: objectSize)
        
        spriteNode.position = .zero // default not apply to screen
        spriteNode.isHidden = true  // default not render
        spriteNode.zPosition = zPosition
        
        if (needBody)
        {
            physicsBody = SKPhysicsBody(rectangleOf: spriteNode.size)
            physicsBody?.isDynamic = !objType.isStatic()        // Able to be move or not
            physicsBody?.affectedByGravity = false              // disable vertical gravity
            physicsBody?.allowsRotation = false
            physicsBody?.categoryBitMask = objType.getPhysicsCAT()
            physicsBody?.contactTestBitMask = contactBitMask // | other category
            physicsBody?.collisionBitMask = collisionBitMask // | other category
            
            // when spriteNode.physicsBody set to nil would disable the body
            spriteNode.physicsBody = physicsBody
        }
    }
    
    convenience init(spriteName: String, objType: eGameObjType,
          objectSize: CGFloat, worldRowCol : CGPoint,
          needBody: Bool = true, zPosition : CGFloat = 0,
          contactBitMask : UInt32 = 0, collisionBitMask : UInt32 = 0)
    {
        let texture = loadSpriteSheet(imageName: spriteName)
        self.init(texture: texture, objType : objType,
             objectSize : objectSize, worldRowCol : worldRowCol,
             needBody: needBody, zPosition : zPosition,
             contactBitMask : contactBitMask, collisionBitMask : collisionBitMask)
    }
    
}
