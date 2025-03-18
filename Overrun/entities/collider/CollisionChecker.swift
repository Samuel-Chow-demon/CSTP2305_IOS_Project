//
//  CollisionChecker.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-18.
//

import Foundation

// -ve offset shrinkage inner, +ve offset enlarge
func IsCollided(objectA : GameObjectBase, objectB : GameObjectBase, offsetInwardA : CGFloat = 0, offsetInwardB : CGFloat = 0) -> Bool
{
    let rectA = CGRect(x: objectA.worldCoordPoint.x, y: objectA.worldCoordPoint.y, width:       objectA.spriteNode.size.width, height: objectA.spriteNode.size.height)
    
    let rectB = CGRect(x: objectB.worldCoordPoint.x, y: objectB.worldCoordPoint.y, width: objectB.spriteNode.size.width, height: objectB.spriteNode.size.height)
    
    return isCollided(rectA, rectB, offsetInwardA, offsetInwardB)
}

func isCollided(_ rectA : CGRect, _ rectB : CGRect, _ offsetInwardA : CGFloat = 0, _ offsetInwardB : CGFloat = 0)->Bool
{
    let rectACheck = rectA.insetBy(dx: -offsetInwardA, dy: -offsetInwardA)
    let rectBCheck = rectB.insetBy(dx: -offsetInwardB, dy: -offsetInwardB)
    
    return rectACheck.intersects(rectBCheck)
}
