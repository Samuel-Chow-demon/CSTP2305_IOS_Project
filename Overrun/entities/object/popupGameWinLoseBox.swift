//
//  popupGameWinLoseBox.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-04-01.
//

import Foundation
import SpriteKit

class PopupGameWinLoseBox{
    
    var popupNode : SKNode!
    var winSloganNode : SKSpriteNode!
    var loseSloganNode : SKSpriteNode!
    
    init(_ frame : CGRect, _ addChild: (SKNode)->Void)
    {
        let boxSize = CGSize(width: 340, height: 340)
        
        // Create a semi-transparent black rounded corner box
        let boxPath = UIBezierPath(roundedRect: CGRect(x: -boxSize.width / 2,
                                                          y: -boxSize.height / 2,
                                                          width: boxSize.width,
                                                          height: boxSize.height),
                                      cornerRadius: 20)

        
        let box = SKShapeNode(path: boxPath.cgPath)
        box.fillColor = UIColor.black.withAlphaComponent(0.7)
        box.strokeColor = .clear
        box.name = "popup box"
        box.zPosition = 95
        box.position = CGPoint(x: frame.midX, y: frame.height + boxSize.height) // Start above screen
        
        // Win or lose
        winSloganNode = SKSpriteNode(imageNamed: "win")
        winSloganNode?.position = CGPoint(x: 0, y: boxSize.height * 0.35)
        
        winSloganNode?.size = CGSize(width: boxSize.width * 0.7, height: boxSize.height * 0.25)
        winSloganNode?.zPosition = 1
        
        winSloganNode?.isHidden = true
        
        loseSloganNode = SKSpriteNode(imageNamed: "gameover")
        //loseSloganNode?.position = CGPoint(x: boxSize.width / 2, y: boxSize.height * 0.75)
        loseSloganNode?.position = CGPoint(x: 0, y: boxSize.height * 0.25)
        loseSloganNode?.size = CGSize(width: boxSize.width * 0.7, height: boxSize.height * 0.25)
        loseSloganNode?.zPosition = 1
        
        loseSloganNode?.isHidden = false // default gameover
        
        
        // Create buttons
        let buttonSize = CGSize(width: 150, height: 40)
        
        let retryButton = createButton(text: "Retry", textNodeName: "retryButton", color: .blue,
                                       buttonSize: buttonSize,
                                        position: CGPoint(x: 0, y: -boxSize.height * 0.15))
        
        let quitButton = createButton(text: "Back To Menu", textNodeName: "quitButton", color: .gray,
                                      buttonSize: buttonSize,
                                        position: CGPoint(x: 0, y: -boxSize.height * 0.3))
        
        box.addChild(winSloganNode)
        box.addChild(loseSloganNode)
        box.addChild(retryButton)
        box.addChild(quitButton)
        
        popupNode = box
        addChild(popupNode)
    }
    
    func createButton(text: String, textNodeName: String, color: UIColor,
                      buttonSize: CGSize,
                      position: CGPoint) -> SKNode
    {
        

        // Create a rounded rectangle button
        let buttonPath = UIBezierPath(roundedRect: CGRect(x: -buttonSize.width / 2,
                                                          y: -buttonSize.height / 2,
                                                          width: buttonSize.width,
                                                          height: buttonSize.height),
                                      cornerRadius: 10)

        let button = SKShapeNode(path: buttonPath.cgPath)
        
        button.fillColor = color
        button.strokeColor = .clear // Remove border
        button.position = position
        button.name = textNodeName // "retryButton"
        button.zPosition = 95

        // Add label on top of the button
        let label = SKLabelNode(text: text)
        label.fontName = "Helvetica-Bold"
        label.fontSize = 18
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: -8) // Center label

        button.addChild(label) // Attach label to the button
        return button
    }
    
    func showPopup(_ frame: CGRect) {
        let moveAction = SKAction.moveTo(y: frame.midY, duration: 0.5) // Move to center
        moveAction.timingMode = .easeOut
        popupNode.run(moveAction)
    }
}

