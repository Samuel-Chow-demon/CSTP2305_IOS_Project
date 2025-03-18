//
//  HeroCharacter.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-11.
//

import Foundation
import SpriteKit

class HeroCharacter : CharacterBase{
    
    var dragStartPosition: CGPoint? = nil
    var isDragging: Bool = false
    
    init(spriteName: String, objectSize: CGFloat, worldCoord : CGPoint,
        contactBitMask : UInt32, collisionBitMask : UInt32)
    {
        super.init(spriteName, objectSize, worldCoord,
                   contactBitMask, collisionBitMask)
        
        // Remind that all the spriteNode default anchor point is (0.5, 0.5) -> the center of the sprite
        // default not apply the position
        spriteNode.position = .zero
    }
}
