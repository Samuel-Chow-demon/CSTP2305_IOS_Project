//
//  GameObjSizeAndViewManager.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-10.
//

import Foundation
import UIKit
import SpriteKit

class GameScreenViewPort: ObservableObject{
    
    static let obj = GameScreenViewPort()
    
    // set to Observable, when screen World Point change, auto trigger render
    @Published var screenWorldPoint: CGPoint
    var currentWorldColRowSize: CGSize
    var worldWidthHeight: CGSize
    var screenWidthHeight: CGSize {
        return getScreenSize()
    }
    
    // preven external init
    private init(){
        self.screenWorldPoint = .zero
        self.currentWorldColRowSize = .zero
        self.worldWidthHeight = .zero
    }
    
    func updateScreenWorldPoint(delta: CGPoint){
        self.screenWorldPoint.x += delta.x
        self.screenWorldPoint.y += delta.y
    }
    
    func getCenterOfTheScreen() -> CGPoint {
        return CGPoint(x: screenWidthHeight.width / 2.0 + screenWorldPoint.x,
                       y: screenWidthHeight.height / 2.0 + screenWorldPoint.y)
    }
}

func getScreenSize()->CGSize{
    return UIScreen.main.bounds.size
}

func getObjectSize()->CGFloat{
    let screenSize = getScreenSize()
    return min(screenSize.width / CGFloat(Constant.SCREEN_TILE_COL),
               screenSize.height / CGFloat(Constant.SCREEN_TILE_ROW))
}

// Check if the spriteNode is fully within the screen bounds
// screenWorldCoord is the bottom left corner world coordinate
func isSpriteNodeWithinScreen(screen : GameScreenViewPort?, gameObj: GameObject) -> Bool {
    
    if (screen == nil)
    {
        return false
    }
    
    let screenWorldPoint = screen!.screenWorldPoint
    let screenWidthHeight = screen!.screenWidthHeight
    
    let bufferX = CGFloat(screenWidthHeight.width / 2) * 1
    let bufferY = CGFloat(screenWidthHeight.height / 2) * 1
    
//    let buffer = max(bufferX, bufferY)
//    
//    let rectA = CGRect(x: screenWorldPoint.x, y: screenWorldPoint.y, width : screenWidthHeight.width, height: screenWidthHeight.height)
    
    let screenBounds = CGRect(x: screenWorldPoint.x - bufferX, y: screenWorldPoint.y -  bufferY,
                              width: screenWidthHeight.width + bufferX, height: screenWidthHeight.height + bufferY)
    
    // Get the sprite's size and position (center)
    let spriteWidth = gameObj.spriteNode.size.width
    let spriteHeight = gameObj.spriteNode.size.height
    let spriteWorldPosition = gameObj.worldCoordPoint
    
//    let rectB = CGRect(x: spriteWorldPosition.x, y: spriteWorldPosition.y, width: spriteWidth, height: spriteHeight)
    
    // -ve means to expand with buffer at rectA
    //return isCollided(rectA, rectB,  (-1) * buffer)

    // Calculate the four corners of the sprite
    let topLeft = CGPoint(x: spriteWorldPosition.x - spriteWidth / 2, y: spriteWorldPosition.y + spriteHeight / 2)
    let topRight = CGPoint(x: spriteWorldPosition.x + spriteWidth / 2, y: spriteWorldPosition.y + spriteHeight / 2)
    let bottomLeft = CGPoint(x: spriteWorldPosition.x - spriteWidth / 2, y: spriteWorldPosition.y - spriteHeight / 2)
    let bottomRight = CGPoint(x: spriteWorldPosition.x + spriteWidth / 2, y: spriteWorldPosition.y - spriteHeight / 2)

    // Check if either one corner is inside the screen bounds
    return screenBounds.contains(topLeft) ||
           screenBounds.contains(topRight) ||
           screenBounds.contains(bottomLeft) ||
           screenBounds.contains(bottomRight)
}
