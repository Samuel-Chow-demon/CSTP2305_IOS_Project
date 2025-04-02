//
//  GameFixedObject.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-04-01.
//

import Foundation
import SpriteKit

class GameFixedObject{
    
    var spriteNode : SKSpriteNode?
    
    convenience init(spriteName: String,
          objectSize: CGFloat,
          fixedCoord : CGPoint,
          zPosition : CGFloat = 100)    // always on top
    {
        self.init(spriteName: spriteName,
              objectSize: CGSize(width: objectSize, height: objectSize),
              fixedCoord : fixedCoord,
              zPosition : zPosition)
    }
    
    convenience init(spriteName: String,
          objectSize: CGSize,
          fixedCoord : CGPoint,
          zPosition : CGFloat = 100)    // always on top
    {
        let texture = loadSpriteSheet(imageName: spriteName)
        self.init(texture: texture,
              objectSize: objectSize,
              fixedCoord : fixedCoord,
              zPosition : zPosition)
    }
    
    init(texture: SKTexture,
          objectSize: CGSize,
          fixedCoord : CGPoint,
          zPosition : CGFloat = 100)    // always on top
    {
        spriteNode = SKSpriteNode(texture: texture)
        spriteNode?.size = objectSize
        spriteNode?.position = fixedCoord
        spriteNode?.zPosition = zPosition
    }
}
