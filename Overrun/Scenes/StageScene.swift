//
//  LandingScene.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-04-01.
//

import Foundation
import SpriteKit
import SwiftUI

class StageScene: SKScene {
    
    var roundedBox: SKShapeNode!

    override func didMove(to view: SKView) {
        setupBackground()
        createRoundedBox()
        setupStartButton()
    }

    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "dungeon")
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.size = self.size  // Scale to fit the screen
        background.zPosition = -99  // Ensure it's behind everything
        
        let appName = SKSpriteNode(imageNamed: "slogan1")
        appName.position = CGPoint(x: self.size.width / 2 + 10, y: self.size.height * 0.75)
        appName.size = CGSize(width: self.frame.width * 0.75, height: self.frame.height * 0.3)
        appName.zPosition = -1  // Ensure it's behind everything
        
        addChild(background)
        addChild(appName)
    }
    
    func createRoundedBox()
    {
        // Create a rounded rectangle background
        let boxSize = CGSize(width: 180, height: 180)
        roundedBox = SKShapeNode(rect: CGRect(origin: CGPoint(x: -boxSize.width/2, y: -boxSize.height/2), size: boxSize), cornerRadius: 30)
        roundedBox.fillColor = .link
        roundedBox.strokeColor = .clear
        roundedBox.name = "roundedBox"
        
        // Create an image node
        let texture = SKTexture(imageNamed: "level_1_icon") // Replace with your image name
        let scale = 0.6
        let imageBoxSize = CGSize(width: boxSize.width * scale, height: boxSize.height * scale)
        let imageNode = SKSpriteNode(texture: texture, size: imageBoxSize)
        imageNode.name = "level1"
        imageNode.zPosition = 1
        
        let levelName = SKLabelNode(text: "STAGE 1")
        levelName.name = "level1"
        levelName.fontName = "Helvetica-Neue"
        levelName.fontSize = 20
        levelName.fontColor = .white
        levelName.zPosition = 2
        
        roundedBox.addChild(levelName)
        
        if let parentNode = levelName.parent {
            let parentCenter = CGPoint(x: parentNode.position.x, y: parentNode.position.y)
            levelName.position = CGPoint(x: parentCenter.x, y: parentCenter.y - (parentNode.frame.height * 0.44))
        }

        // Position elements
        roundedBox.position = CGPoint(x: frame.midX, y: frame.midY - 40)
        imageNode.position = .zero
        
        roundedBox.addChild(imageNode)
        
        // Add to the scene
        addChild(roundedBox)
    }

    func setupStartButton() {
        let startButton = SKLabelNode(text: "Start")
        startButton.name = "startButton"
        startButton.fontName = "Helvetica-Neue"
        startButton.fontSize = 40
        startButton.fontColor = .white
        startButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.2)
        
        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.3)
        let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 0.3)

        // Sequence and repeat
        let bounceAction = SKAction.sequence([moveUp, moveDown])
        let repeatBounce = SKAction.repeatForever(bounceAction)

        // Run the action
        startButton.run(repeatBounce)
        
        addChild(startButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)

            if touchedNode.name == "startButton" {
                goToGameScene()
            }
        }
    }

    func goToGameScene() {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .resizeFill
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(gameScene, transition: transition)
    }
}

struct StageContentView: View{
    var scene = StageScene(size: CGSize(width: 402, height: 874)) // Iphone 16 Pro screen size
    var body: some View{
        VStack{
            SpriteView(scene : scene)
                .ignoresSafeArea()
                .frame(width:402, height:874)
        }
    }
}

#Preview("StageContentView")
{
    StageContentView()
}
