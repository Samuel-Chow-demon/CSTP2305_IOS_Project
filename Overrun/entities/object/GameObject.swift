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
          colliderSizeRatio: CGFloat = 1.0,
          needBody: Bool = true,
          zPosition : CGFloat = 0,
          contactBitMask : UInt32 = 0, collisionBitMask : UInt32 = 0)
    {
        let worldCoord = CGPoint(x: CGFloat(worldRowCol.x) * objectSize + objectSize / 2,
                                   y: CGFloat(worldRowCol.y) * objectSize + objectSize / 2 + Constant.BACKGROUND_BOTTOM_OFFSET)
        super.init(objType, worldCoord)
        
        spriteTexture = texture
        spriteNode = SKSpriteNode(texture: spriteTexture)
        spriteNode.name = Constant.SPRITE_NODE_NON_COLLIDABLE
        //spriteNode.name = needBody ? Constant.SPRITE_NODE_COLLIDABLE : Constant.SPRITE_NODE_NON_COLLIDABLE
        
        spriteNode.userData = NSMutableDictionary()
        spriteNode.userData =
            [
                Constant.USER_FLAG_ID            : "\(objType.rawValue)_\(worldCoord.x)_\(worldCoord.y)",
                Constant.USER_FLAG_GET_HARM      : false,
                Constant.USER_FLAG_IS_INVINCIBLE : false
            ]
        
        spriteNode.size = CGSize(width: objectSize, height: objectSize)
        
        spriteNode.position = .zero // default not apply to screen
        spriteNode.isHidden = true  // default not render
        spriteNode.zPosition = zPosition
        
        if (needBody)
        {
            // 1 - Create Physics Body
            let physicCAT = objType.getPhysicsCAT()
            
            let attackableMask = ((physicCAT & PhysicsCategory.attackable != 0) ? PhysicsCategory.playerAttack : 0)
            
            physicsBody = SKPhysicsBody(rectangleOf: spriteNode.size)
            physicsBody?.isDynamic = !objType.isStatic()        // Able to be move or not
            physicsBody?.affectedByGravity = false              // disable vertical gravity
            physicsBody?.allowsRotation = false
            physicsBody?.categoryBitMask = physicCAT
            physicsBody?.contactTestBitMask = contactBitMask | attackableMask
            physicsBody?.collisionBitMask = 0 // spriteNode not for collision
            
//            print("Object Type: \(objType), Cat: \(physicsBody?.categoryBitMask), contact : \(physicsBody?.contactTestBitMask)")
            
            // when spriteNode.physicsBody set to nil would disable the body
            spriteNode.physicsBody = physicsBody
            
            // 2 - Display Use
            spriteDisplayPhysicsBodyNode = SKShapeNode(rectOf: spriteNode.size)
            spriteDisplayPhysicsBodyNode?.fillColor = .magenta
            spriteDisplayPhysicsBodyNode?.strokeColor = .blue
            spriteDisplayPhysicsBodyNode?.lineWidth = 2
            spriteDisplayPhysicsBodyNode?.position = spriteNode.position
            spriteDisplayPhysicsBodyNode?.isHidden = true // default hidden
            
            spriteNode.addChild(spriteDisplayPhysicsBodyNode!)
            
            // 3 - create specific for collision purpose, smaller than the sprite node that display the
            // texture
            spriteCollisionNode = SKSpriteNode(color: .blue, size: CGSize(width: objectSize *                           colliderSizeRatio, height: objectSize * colliderSizeRatio))
            
            spriteCollisionNode?.name = Constant.SPRITE_NODE_COLLIDABLE
            
            // relative to the parent sprite node is zero
            spriteCollisionNode?.position = .zero
            spriteCollisionNode?.zPosition = spriteNode.zPosition + 1
            
            spriteCollisionNode?.physicsBody = SKPhysicsBody(rectangleOf: spriteCollisionNode!.size)
            spriteCollisionNode?.physicsBody?.isDynamic = !objType.isStatic()
            spriteCollisionNode?.physicsBody?.affectedByGravity = false
            spriteCollisionNode?.physicsBody?.allowsRotation = false
            spriteCollisionNode?.physicsBody?.categoryBitMask = PhysicsCategory.collidable
            spriteCollisionNode?.physicsBody?.contactTestBitMask = 0
            spriteCollisionNode?.physicsBody?.collisionBitMask = collisionBitMask
        }
    }
    
    convenience init(spriteName: String, objType: eGameObjType,
          objectSize: CGFloat, worldRowCol : CGPoint,
          colliderSizeRatio: CGFloat,
          needBody: Bool = true, zPosition : CGFloat = 0,
          contactBitMask : UInt32 = 0, collisionBitMask : UInt32 = 0)
    {
        let texture = loadSpriteSheet(imageName: spriteName)
        self.init(texture: texture, objType : objType,
             objectSize : objectSize, worldRowCol : worldRowCol,
             colliderSizeRatio: colliderSizeRatio,
             needBody: needBody, zPosition : zPosition,
             contactBitMask : contactBitMask, collisionBitMask : collisionBitMask)
    }
    
    override func implementAddNodeToScene(_ addChild: (SKNode) -> Void) {
        
        addChild(spriteNode)
        if spriteCollisionNode != nil{
            addChild(spriteCollisionNode!)
        }
    }
    
}
