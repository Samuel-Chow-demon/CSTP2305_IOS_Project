//
//  ColliderManager.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-28.
//

import Foundation
import SpriteKit

class ColliderManager{
    
    // Define a custom struct that conforms to Hashable since
    // SKSpriteNode do not able be hashable directly and be used in a Set<>
    struct NodePair: Hashable
    {
        var nodeA: SKSpriteNode
        var nodeB: SKSpriteNode
        
        // Implement hashable requirement
        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(nodeA))
            hasher.combine(ObjectIdentifier(nodeB))
        }
        
        // Implement Equatable requirement for Hashable
        static func ==(lhs: NodePair, rhs: NodePair) -> Bool {
            return lhs.nodeA == rhs.nodeA && lhs.nodeB == rhs.nodeB
        }
    }
    
    // Store current active pair of node overlapped
    private var activeCollisions: Set<NodePair> = []
    
    // setup a thread safe ordered queue in a separated thread
    // to handle node pair register, unregister and checking sequence
    let collisionQueue = DispatchQueue(label : "collisionQueue") // a serial Queue
    
    func clearAll()
    {
        activeCollisions.removeAll()
    }
    
    func registerCollision(_ node1: SKSpriteNode, _ node2: SKSpriteNode){
        collisionQueue.async {
            let nodePair = NodePair(nodeA: node1, nodeB : node2)
            self.activeCollisions.insert(nodePair)
        }
    }
    
    func unRegisterCollision(_ node1: SKSpriteNode, _ node2: SKSpriteNode){
        collisionQueue.async {
            let nodePair = NodePair(nodeA: node1, nodeB : node2)
            self.activeCollisions.remove(nodePair)
        }
    }
    
    func checkAndHandleCollides()
    {
        collisionQueue.sync {
            
            for nodePair in self.activeCollisions {
                
                let nodeA = nodePair.nodeA
                let nodeB = nodePair.nodeB
                
                let nodeAPhysicsBody = nodeA.physicsBody
                let nodeBPhysicsBody = nodeB.physicsBody
                
                let nodeACatBitMask = nodeAPhysicsBody?.categoryBitMask
                let nodeBCatBitMask = nodeBPhysicsBody?.categoryBitMask
                
                if nodeACatBitMask == nil || nodeBCatBitMask == nil ||
                    nodeAPhysicsBody! == nodeBPhysicsBody!
                {
                    continue
                }
                
                // 1 - when nodeB is object
                
                // if it is attackable
                if (nodeBCatBitMask! & PhysicsCategory.attackable != 0)
                {
                    // if node A have the attack collider
                    if (nodeACatBitMask! & PhysicsCategory.playerAttack != 0)
                    {
                        // check if nodeA player attack collider is in attacking state
                        if let isAttacking = nodeA.userData?[Constant.USER_FLAG_IS_ATTACKING] as? Bool,
                           let isOtherInvincible = nodeB.userData?[Constant.USER_FLAG_IS_INVINCIBLE] as? Bool,
                           
                            // if A is attacking and other is not at invincible state
                            // able to attack B
                            isAttacking, !isOtherInvincible
                        {
                            // then set the nodeB object get harm
                            nodeB.userData![Constant.USER_FLAG_GET_HARM] = true
                        }
                    }
                }
                
                // 2 - when nodeA is object
                
                // if it is attackable
                if (nodeACatBitMask! & PhysicsCategory.attackable != 0)
                {
                    // if node B have the attack collider
                    if (nodeBCatBitMask! & PhysicsCategory.playerAttack != 0)
                    {
                        // check if nodeB player attack collider is in attacking state
                        if let isAttacking = nodeB.userData?[Constant.USER_FLAG_IS_ATTACKING] as? Bool,
                            let isOtherInvincible = nodeA.userData?[Constant.USER_FLAG_IS_INVINCIBLE] as? Bool,
                           
                            // if B is attacking and other is not at invincible state
                            // able to attack A
                            isAttacking, !isOtherInvincible
                        {
                            // then set the nodeA object get harm
                            nodeA.userData![Constant.USER_FLAG_GET_HARM] = true
                        }
                    }
                }
                
                // 3 - check if hero suffer harm
                
                // if object b is harmful
                if (nodeBCatBitMask! & PhysicsCategory.harmful != 0 &&
                    nodeACatBitMask! & PhysicsCategory.player != 0)
                {
                    if let isAInvincible = nodeA.userData?[Constant.USER_FLAG_IS_INVINCIBLE] as? Bool, !isAInvincible
                    {
                        // then set the nodeA object get harm
                        nodeA.userData![Constant.USER_FLAG_GET_HARM] = true
                    }
                }
                
                // if object a is harmful
                if (nodeACatBitMask! & PhysicsCategory.harmful != 0 &&
                    nodeBCatBitMask! & PhysicsCategory.player != 0)
                {
                    if let isBInvincible = nodeB.userData?[Constant.USER_FLAG_IS_INVINCIBLE] as? Bool, !isBInvincible
                    {
                        // then set the nodeB object get harm
                        nodeB.userData![Constant.USER_FLAG_GET_HARM] = true
                    }
                }
            }
        }
    }
    
    
    // The didEnd would optimize the contact fire that sometimes only
    // call the first pair that trigger the leave contact action
    // remaining the others missed to unregister
    // thus need to explicitly check if two node are stil in contact or not
    func checkAndRemoveRegistry()
    {
        collisionQueue.sync {
            
            var pairsToRemove : [NodePair] = []
            
            for nodePair in self.activeCollisions {
                
                let nodeA = nodePair.nodeA
                let nodeB = nodePair.nodeB
                
                let nodeAPhysicsBody = nodeA.physicsBody
                let nodeBPhysicsBody = nodeB.physicsBody
                
                if nodeAPhysicsBody! == nodeBPhysicsBody!
                {
                    continue
                }
                
                if (!nodeA.frame.intersects(nodeB.frame))
                {
                    pairsToRemove.append(nodePair)
                }
            }
            
            self.activeCollisions.subtract(pairsToRemove)
        }
    }
}
