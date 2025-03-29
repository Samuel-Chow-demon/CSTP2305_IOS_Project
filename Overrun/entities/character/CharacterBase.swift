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

    var dragStartPosition: CGPoint? = nil
    var isDragging: Bool = false
    
    var moveTexture : [[SKTexture]] = [[]]
    var attackTexture : [SKTexture] = []
    
    // init as nil, can have or not
    var attackSpriteNode : [SKSpriteNode?] = [SKSpriteNode?](repeating: nil, count: 4)
    var beforeAttackPos : CGPoint = CGPoint(x: 0, y: 0)
    var beforeAttackSize : CGSize = CGSize(width: 0, height: 0)
    var curAttackDirIdx : Int = 0
    var isStartAttack: Bool = false
    
    // For Arrow Indicator
    var triangleNode, circleNode: SKShapeNode!
    var triangleBlurNode, circleBlurNode : SKEffectNode!
    var eCurDir: eDirection = eDirection.eDOWN // default pointing downward
    
    // Timing for alternating sprite textures
    var lastTextureUpdateTime: TimeInterval = 0
    // In Second Unit
    var textureChangeInterval: TimeInterval = 0.2 // 200 ms default
    var currentTextureIndex: Int = 0
    
    var lastAttackTextureStartTime: TimeInterval = 0
    
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
        
        spriteNode.userData =
            [
                Constant.USER_FLAG_GET_HARM     : false,
                Constant.USER_FLAG_IS_INVINCIBLE : false
            ]
        
        // Always on top
        spriteNode.color = .red             // prepare the be harm color
        spriteNode.colorBlendFactor = 0.0   // default not to display
        spriteNode.alpha = 1.0
        spriteNode.zPosition = 99
        
        // get Harm response
        getHarm.color = .red
        getHarm.invincibleCycle = 3
        getHarm.cycleInterval = 0.03
        // use default 50ms per interval
        
        // Add the physics body for the hero
        spriteNode.physicsBody = SKPhysicsBody(rectangleOf: spriteNode.size)
        spriteNode.physicsBody?.isDynamic = true
        spriteNode.physicsBody?.affectedByGravity = false  //disable vertical gravity
        spriteNode.physicsBody?.allowsRotation = false
        spriteNode.physicsBody?.categoryBitMask = PhysicsCategory.player
        spriteNode.physicsBody?.contactTestBitMask = contactBitMask | PhysicsCategory.harmful
        spriteNode.physicsBody?.collisionBitMask = collisionBitMask
        
        // Init the Drag Movement Indicator
        triangleNode = SKShapeNode(path: DragArrowPath(in: CGRect(), angle: 0.0).cgPath) // hero.triangleShape.path(in: self.frame).cgPath)
        triangleNode.lineWidth = 2
        triangleNode.fillColor = .lightGray
        triangleNode.strokeColor = .clear
        triangleNode.fillShader = gradientShader
        triangleNode.position = CGPoint(x:0, y:0)
        triangleNode.isHidden = true // initial is hidden
        
        triangleBlurNode = SKEffectNode()
        triangleBlurNode.addChild(triangleNode)
        triangleBlurNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10])
        triangleBlurNode.shouldRasterize = true  // Improves performance
        triangleBlurNode.zPosition = 99
        
        circleNode = SKShapeNode(circleOfRadius: 25)
        circleNode.fillColor = .lightGray
        circleNode.strokeColor = .clear
        circleNode.lineWidth = 2
        circleNode.position = CGPoint(x:0, y:0)
        circleNode.isHidden = true
        
        circleBlurNode = SKEffectNode()
        circleBlurNode.addChild(circleNode)
        circleBlurNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10])
        circleBlurNode.shouldRasterize = true  // Improves performance
        circleBlurNode.zPosition = 99
    }
    
    func setupAttackSpriteNode(attackSpritePredix : String)
    {
        // sequence follow the eDir enum
        attackTexture = [
            loadSpriteSheet(imageName: attackSpritePredix + "_right_hit"),
            loadSpriteSheet(imageName: attackSpritePredix + "_left_hit"),
            loadSpriteSheet(imageName: attackSpritePredix + "_up_hit"),
            loadSpriteSheet(imageName: attackSpritePredix + "_down_hit"),
        ]
        
        for i in 0..<attackSpriteNode.count{
                
            let extendedSize = spriteNode.size.width * (Constant.DEFAULT_INTERACT_SIZE_EXTEND_RATIO - 1)
            let width = (i == eDirection.eLEFT.rawValue || i == eDirection.eRIGHT.rawValue) ?         extendedSize : spriteNode.size.width
            let height = (i == eDirection.eUP.rawValue || i == eDirection.eDOWN.rawValue) ?         extendedSize : spriteNode.size.height
            
            // Create Node
            attackSpriteNode[i] = SKSpriteNode(color: .clear, size: CGSize(width: width, height: height))
            
            attackSpriteNode[i]?.userData =
            [
                Constant.USER_FLAG_IS_ATTACKING : false,
            ]
            
            // would auto move related to the spriteNode when move
            attackSpriteNode[i]?.position = CGPoint(x: 0, y: 0)
            
            // one above the body sprite node to cover the original sprite when activate
            attackSpriteNode[i]?.zPosition = spriteNode.zPosition + 1
            
            // not hidden
            attackSpriteNode[i]?.isHidden = false
            
            // Add Physics
            attackSpriteNode[i]?.physicsBody = SKPhysicsBody(rectangleOf: attackSpriteNode[i]!.size)
            attackSpriteNode[i]?.physicsBody?.isDynamic = true
            attackSpriteNode[i]?.physicsBody?.affectedByGravity = false
            attackSpriteNode[i]?.physicsBody?.allowsRotation = false
            attackSpriteNode[i]?.physicsBody?.categoryBitMask = PhysicsCategory.playerAttack
            attackSpriteNode[i]?.physicsBody?.contactTestBitMask = spriteNode.physicsBody!.contactTestBitMask          // contact is the same as the body sprite configure
            attackSpriteNode[i]?.physicsBody?.collisionBitMask = 0 // should be no block for attack region
            
//            print("attack SpriteNode :\(attackSpriteNode[i]?.physicsBody?.contactTestBitMask)")
        }
    }
    
    override func implementAddNodeToScene(_ addChild: (SKNode) -> Void) {
        
        addChild(spriteNode)
        addChild(triangleBlurNode)
        addChild(circleBlurNode)
        
        if (!attackSpriteNode.isEmpty)
        {
            attackSpriteNode.forEach{ node in
                
                if node != nil{
                    addChild(node!)
                }
            }
        }
    }
    
    func displayOnOffAttackBox(_ isDisplay : Bool)
    {
        attackSpriteNode.forEach { node in
            if node != nil{
                node?.color = isDisplay ? .blue : .clear
            }
        }
    }
    
    func handleAttackSprite()
    {
        // means start attack
        if (isStartAttack &&
            !isDragging &&
            lastAttackTextureStartTime == 0)
        {
            isStartAttack = false
            //print("Start Attack")
            changeToAttackSprite()
            lastAttackTextureStartTime = CACurrentMediaTime()
        }
        else if (lastAttackTextureStartTime != 0)
        {
            let currentTime = CACurrentMediaTime()
            let timeDelta = currentTime - lastAttackTextureStartTime
            if (timeDelta > 0.05 || isDragging) // 200 ms
            {
                //print("Resume back to normal")
                resumeSpriteFromAttack()
            }
        }
    }
    
    private func changeToAttackSprite()
    {
        attackSpriteNode[eCurDir.rawValue]!.userData![Constant.USER_FLAG_IS_ATTACKING] = true
        curAttackDirIdx = eCurDir.rawValue
        beforeAttackPos = spriteNode.position
        beforeAttackSize = spriteNode.size
        
        var offset = CGPoint(x: 0, y: 0)
        switch eCurDir {
            case .eRIGHT:
                offset = CGPoint(x: (attackSpriteNode[eCurDir.rawValue]!.size.width / 2), y: 0)
            case .eLEFT:
                offset = CGPoint(x: -1 * (attackSpriteNode[eCurDir.rawValue]!.size.width / 2), y: 0)
            case .eUP:
                offset = CGPoint(x: 0, y: (attackSpriteNode[eCurDir.rawValue]!.size.height / 2))
            case .eDOWN:
                offset = CGPoint(x: 0, y: -1 * (attackSpriteNode[eCurDir.rawValue]!.size.height / 2))
        }
        
        spriteNode.position.x += offset.x
        spriteNode.position.y += offset.y
        
        spriteNode.size.width += abs(offset.x) * 2
        spriteNode.size.height += abs(offset.y) * 2
        
        spriteNode.texture = attackTexture[eCurDir.rawValue]
    }
    
    func resumeSpriteFromAttack()
    {
        spriteNode.position = beforeAttackPos
        spriteNode.size = beforeAttackSize
        updateSpriteNodeTexture(eDir : eCurDir, index : 0)
        lastAttackTextureStartTime = 0
        attackSpriteNode[curAttackDirIdx]!.userData![Constant.USER_FLAG_IS_ATTACKING] = false
    }
    
    private func updateSpriteNodeTexture(eDir: eDirection, index : Int)
    {
        if moveTexture.indices.contains(eDir.rawValue) &&
            moveTexture[eDir.rawValue].indices.contains(index)
        {
            //print("Update Sprite Texture")
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
    
    func updateSpritePosition(_ newPos : CGPoint)
    {
        spriteNode.position = newPos
        
        attackSpriteNode.enumerated().forEach{ (index, node) in
            
            if node != nil
            {
                var offset = CGPoint(x: 0, y: 0)
                switch index
                {
                    case eDirection.eUP.rawValue:
                        offset = CGPoint(x: 0, y: (spriteNode.size.height + node!.size.height) / 2)
                    case eDirection.eDOWN.rawValue:
                        offset = CGPoint(x: 0, y: -1 * (spriteNode.size.height + node!.size.height) / 2)
                    case eDirection.eLEFT.rawValue:
                        offset = CGPoint(x: -1 * (spriteNode.size.width + node!.size.width) / 2, y: 0)
                    case eDirection.eRIGHT.rawValue:
                        offset = CGPoint(x: (spriteNode.size.width + node!.size.width) / 2, y: 0)
                    default:
                        break
                }
                
                node!.position.x = spriteNode.position.x + offset.x
                node!.position.y = spriteNode.position.y + offset.y
            }
        }
    }
    
    func Move(delta: CGPoint)
    {
        let newPos = CGPoint(x: spriteNode.position.x + delta.x, y: spriteNode.position.y + delta.y)
        updateSpritePosition(newPos)
    }
    
    func RepelMove()
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
        
        Move(delta: delta)
    }
}
