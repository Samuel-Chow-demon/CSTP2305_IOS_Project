//
//  GameObject.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-17.
//

import Foundation
import SpriteKit

// Interface child must implement
protocol GameObjectProtocal{
    func implementAddNodeToScene(_ addChild: (SKNode)-> Void)
}

class GameObjectBase : GameObjectProtocal{
    
    struct getHarmConfig{
        var color : SKColor = .darkGray
        var invincibleCycle : Int = 1
        var cycleInterval: Double = 0.05 // 50 ms default per blink cycle if have invincible cycle
    }
    
    var eObjectType : eGameObjType
    var worldCoordPoint : CGPoint = .zero
    
    var spriteNode: SKSpriteNode!
    var spriteCollisionNode: SKSpriteNode?
    
    var spriteDisplayPhysicsBodyNode: SKShapeNode?
    
    var spriteTexture : SKTexture!
    var physicsBody: SKPhysicsBody!
    
    var getHarm : getHarmConfig = .init()
    
    init(_ eObjType : eGameObjType,
         _ worldCoord: CGPoint)
    {
        eObjectType = eObjType
        worldCoordPoint = worldCoord
    }
    
    func addNodeToScene(_ addChild: (SKNode)-> Void)
    {
        implementAddNodeToScene(addChild)
    }
    
    func implementAddNodeToScene(_ addChild: (SKNode) -> Void) {
        // default do nothing
    }
    
    func displayOnOffNodeBox(_ isDisplay : Bool)
    {
        if spriteDisplayPhysicsBodyNode != nil{
            spriteDisplayPhysicsBodyNode?.isHidden = !isDisplay
        }
        
        if spriteCollisionNode != nil
        {
            spriteCollisionNode?.color = isDisplay ? .blue : .clear
        }

    }
    
    // create recursive function
    private func startHarmEffect(cycle: Int)
    {
        guard cycle > 0 else {
            self.spriteNode.userData![Constant.USER_FLAG_IS_INVINCIBLE] = false
            return // quit if cycle finish
        }
        // Schedule a task in background thread in low priority with 50 ms after
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + getHarm.cycleInterval) {
            
            // Need switch back to main thread when control UI attribute to prevent wrong behaviour
            DispatchQueue.main.async{
                self.spriteNode.colorBlendFactor = 0.0 // off the color cover effect
            }
            
            if (cycle - 1 <= 0)
            {
                self.spriteNode.userData![Constant.USER_FLAG_IS_INVINCIBLE] = false
                return
            }
            
            // Schedule a task in background thread in low priority with 50 ms after
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + self.getHarm.cycleInterval) {
                
                // Need switch back to main thread when control UI attribute to prevent wrong behaviour
                DispatchQueue.main.async{
                    self.spriteNode.colorBlendFactor = 1.0 // on the color cover effect
                }
                
                self.startHarmEffect(cycle: cycle - 1)
            }
        }
    }
    
    func handleGetHarmResponse() -> Bool
    {
        // means start being harm
        if let isBeingHarm = spriteNode.userData?[Constant.USER_FLAG_GET_HARM] as? Bool
        {
            if (isBeingHarm)
            {
                spriteNode.userData![Constant.USER_FLAG_IS_INVINCIBLE] = true
                spriteNode.userData![Constant.USER_FLAG_GET_HARM] = false
                spriteNode.color = getHarm.color
                spriteNode.colorBlendFactor = 1.0
                spriteNode.alpha = 0.8
 
                startHarmEffect(cycle: getHarm.invincibleCycle)
                return true
            }
        }
        return false
    }
    
    func checkIfNeedRenderHandle(_ viewPort : GameScreenViewPort, _ needDraw: Bool)
    {
        if (needDraw)
        {
            let screenWorldX = viewPort.screenWorldPoint.x
            let screenWorldY = viewPort.screenWorldPoint.y
            let objWorldX = worldCoordPoint.x
            let objWorldY = worldCoordPoint.y
            
            // Update texture position
            spriteNode.position = CGPoint(x:objWorldX - screenWorldX, y:objWorldY - screenWorldY)
            spriteCollisionNode?.position = spriteNode.position
            
            // suppress the return catpure warning
            _ = handleGetHarmResponse()
        }

        spriteNode.isHidden = !needDraw
    }
}
