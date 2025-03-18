//
//  CharacterBase.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-11.
//

import Foundation
import SpriteKit

class CharacterBase : GameObjectBase {
    
    // the spriteNode already had the .position keep updating the current position

    var moveTexture : [[SKTexture]] = [[]]
    // For Arrow Indicator
    var triangleNode: SKShapeNode!
    var triangleBlurNode : SKEffectNode!
    var eCurDir: eDirection = eDirection.eDOWN // default pointing downward
    
    // Timing for alternating sprite textures
    var lastTextureUpdateTime: TimeInterval = 0
    // In Second Unit
    var textureChangeInterval: TimeInterval = 0.2 // 200 ms default
    var currentTextureIndex: Int = 0
    
    // Contact - trigger didBegin, didEnd callback
    // Collision - block the movement
    init(_ spriteName: String, _ objectSize: CGFloat,
         _ worldCoord: CGPoint,
         _ contactBitMask : UInt32, _ collisionBitMask : UInt32)
    {
        super.init(eGameObjType.eCHARACTER, worldCoord)
        
        moveTexture = loadSpriteSheet(imageName: spriteName, sheetCols: 2, sheetRows: 4)
        spriteNode = SKSpriteNode(texture: moveTexture[eDirection.eDOWN.rawValue][0])
        spriteNode.size = CGSize(width: objectSize, height: objectSize)
        
        // Always on top
        spriteNode.zPosition = 99
        
        // Add the physics body for the hero
        spriteNode.physicsBody = SKPhysicsBody(rectangleOf: spriteNode.size)
        spriteNode.physicsBody?.isDynamic = true
        spriteNode.physicsBody?.affectedByGravity = false  //disable vertical gravity
        spriteNode.physicsBody?.allowsRotation = false
        spriteNode.physicsBody?.categoryBitMask = PhysicsCategory.player
        spriteNode.physicsBody?.contactTestBitMask = contactBitMask
        spriteNode.physicsBody?.collisionBitMask = collisionBitMask
        
        // Init the Drag Movement Indicator
        triangleNode = SKShapeNode(path: DragArrowPath(in: CGRect(), angle: 0.0).cgPath) // hero.triangleShape.path(in: self.frame).cgPath)
        triangleNode.lineWidth = 2
        triangleNode.fillColor = .lightGray
        triangleNode.strokeColor = .clear
        triangleNode.fillShader = gradientShader
        triangleNode.position = CGPoint(x:0, y:0)
        triangleNode.isHidden = true // initial is hidden
        triangleNode.zPosition = 99
        
        triangleBlurNode = SKEffectNode()
        triangleBlurNode.addChild(triangleNode)
        triangleBlurNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10])
        triangleBlurNode.shouldRasterize = true  // Improves performance
    }
    
    
    
    private func updateSpriteNodeTexture(eDir: eDirection, index : Int)
    {
        if moveTexture.indices.contains(eDir.rawValue) &&
            moveTexture[eDir.rawValue].indices.contains(index)
        {
            spriteNode.texture = moveTexture[eDir.rawValue][index]
        }
    }
    
    // Function to alternate textures for sprite based on drag direction and timing
    func updateTextureForDirection(_ angle: CGFloat)
    {
        let currentTime = CACurrentMediaTime()
        let timeDelta = currentTime - lastTextureUpdateTime
        let angleInDeg = angle * 180 / CGFloat.pi
        
        //print("timeDelta : \(timeDelta), Interval : \(textureChangeInterval)")
        print("angleInDeg : \(angleInDeg)")
        
        // Determine the direction based on the angle of movement
        if angleInDeg >= -45 && angleInDeg < 45
        {
            // Right direction
            eCurDir = eDirection.eRIGHT
        }
        else if angleInDeg >= 45 && angleInDeg < 135
        {
            // Up direction
            eCurDir = eDirection.eUP
        }
        else if angleInDeg >= 135 && angleInDeg <= 180 || angleInDeg < -135 && angleInDeg >= -180
        {
            // Left direction
            eCurDir = eDirection.eLEFT
        }
        else
        {
            // Down direction
            eCurDir = eDirection.eDOWN
        }
        
        print("current Direction : \(eCurDir)")
        
        // Update texture every certain period for alternating textures
        if timeDelta >= textureChangeInterval
        {
            // Direct update to the node texture can render
            updateSpriteNodeTexture(eDir : eCurDir, index : currentTextureIndex)
            
            // Alternate between two textures every interval
            currentTextureIndex = (currentTextureIndex == 0) ? 1 : 0
            
            // Update the last update time for texture change
            lastTextureUpdateTime = currentTime
        }
    }
}
