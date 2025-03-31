//
//  HeroCharacter.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-11.
//

import Foundation
import SpriteKit

class HeroCharacter : CharacterBase{
    
    
    init(eObjectType : eGameObjType, objectSize: CGFloat, worldCoord : CGPoint,
        contactBitMask : UInt32, collisionBitMask : UInt32)
    {
        super.init(eObjectType,
                   Constant.DEFAULT_HERO_HEALTH, Constant.DEFAULT_HERO_SPEED,
                   objectSize,
                   worldCoord,
                   contactBitMask, collisionBitMask)
        
        // Remind that all the spriteNode default anchor point is (0.5, 0.5) -> the center of the sprite
        // default not apply the position
        spriteNode.position = .zero
        
        // Init the Drag Movement Indicator
        triangleNode = SKShapeNode(path: DragArrowPath(in: CGRect(), angle: 0.0).cgPath) // hero.triangleShape.path(in: self.frame).cgPath)
        triangleNode?.lineWidth = 2
        triangleNode?.fillColor = .lightGray
        triangleNode?.strokeColor = .clear
        triangleNode?.fillShader = gradientShader
        triangleNode?.position = CGPoint(x:0, y:0)
        triangleNode?.isHidden = true // initial is hidden
        
        triangleBlurNode = SKEffectNode()
        triangleBlurNode?.addChild(triangleNode!)
        triangleBlurNode?.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10])
        triangleBlurNode?.shouldRasterize = true  // Improves performance
        triangleBlurNode?.zPosition = 99
        
        circleNode = SKShapeNode(circleOfRadius: 25)
        circleNode?.fillColor = .lightGray
        circleNode?.strokeColor = .clear
        circleNode?.lineWidth = 2
        circleNode?.position = CGPoint(x:0, y:0)
        circleNode?.isHidden = true
        
        circleBlurNode = SKEffectNode()
        circleBlurNode?.addChild(circleNode!)
        circleBlurNode?.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10])
        circleBlurNode?.shouldRasterize = true  // Improves performance
        circleBlurNode?.zPosition = 99
        
        setupAttackSpriteNode(attackSpritePredix : eObjectType.spriteName)
    }
    
    func updatePos(_ currentView : GameScreenViewPort)
    {
        let centerOfScreen = currentView.getCenterOfTheScreen()
        
        //spriteNode.position.x = centerOfScreen.x - currentView.screenWorldPoint.x
        //spriteNode.position.y = centerOfScreen.y - currentView.screenWorldPoint.y
        
        updateSpritePosition(CGPoint(x: centerOfScreen.x - currentView.screenWorldPoint.x,
                                     y: centerOfScreen.y - currentView.screenWorldPoint.y))
        self.worldCoordPoint = centerOfScreen
    }
    
    func HeroMove(viewport : GameScreenViewPort, delta: CGPoint)
    {
        viewport.updateScreenWorldPoint(delta : delta)
        updatePos(viewport)
    }
    
    func HeroRepelMove(viewport : GameScreenViewPort,
                        beforeMoveCheckIsBlock: (CGPoint, CGSize, CGFloat)->Bool)
    {
        var delta : CGPoint = .zero
        
        switch eCurDir {
            case .eRIGHT:
                delta.x = -1 * Constant.DEFAULT_HERO_HARM_REPEL_DISTANCE
            case .eLEFT:
                delta.x = Constant.DEFAULT_HERO_HARM_REPEL_DISTANCE
            case .eUP:
                delta.y = -1 * Constant.DEFAULT_HERO_HARM_REPEL_DISTANCE
            case .eDOWN:
                delta.x = Constant.DEFAULT_HERO_HARM_REPEL_DISTANCE
        }
        
        let futurePosition = CGPoint(x: spriteNode.position.x + delta.x,
                                     y: spriteNode.position.y + delta.y)
        
        if (!beforeMoveCheckIsBlock(futurePosition, spriteNode.size, Constant.CHARACTER_MOVE_COLLIDER_BUFFER))
        {
            HeroMove(viewport : viewport, delta: delta)
        }
    }
}
