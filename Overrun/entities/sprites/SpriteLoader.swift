//
//  SpriteLoader.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-10.
//

import Foundation
import SpriteKit

func loadSpriteSheet(imageName: String, sheetCols : Int, sheetRows : Int)-> [[SKTexture]]{
    let spriteSheetImage = SKTexture(imageNamed: imageName)
    
    let sheetWidth = spriteSheetImage.size().width
    let sheetHeight = spriteSheetImage.size().height
    
    let frameWidth = sheetWidth / CGFloat(sheetCols)
    let frameHeight = sheetHeight / CGFloat(sheetRows)
    
    var spriteSheetTextures : [[SKTexture]] = Array(repeating: [], count: sheetRows)
    
    for row in 0..<sheetRows{
        
        for col in 0..<sheetCols{
            
            // CGRect is Bottom to top, left to right, it used 0.0 to 1.0 normalized value
            let rect = CGRect(x : CGFloat(col) * frameWidth / sheetWidth,
                              y : CGFloat(row) * frameHeight / sheetHeight,
                              width: frameWidth / sheetWidth,
                              height: frameHeight / sheetHeight)
            
            spriteSheetTextures[row].append(SKTexture(rect: rect, in: spriteSheetImage))
            
        }
    }
    return spriteSheetTextures
}

func loadSpriteSheet(imageName: String)->SKTexture{
    return SKTexture(imageNamed: imageName)
}
