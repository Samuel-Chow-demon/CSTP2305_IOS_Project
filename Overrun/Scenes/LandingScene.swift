//
//  LandingScene.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-04-01.
//

import Foundation
import SpriteKit
import SwiftUI

class LandingScene: SKScene {

    override func didMove(to view: SKView) {
        setupBackground()
        setupStartButton()
    }

    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "landing")
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.size = self.size  // Scale to fit the screen
        background.zPosition = -99  // Ensure it's behind everything
        
        let appName = SKSpriteNode(imageNamed: "overrun")
        appName.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.6)
        appName.size = CGSize(width: self.frame.width * 0.9, height: self.frame.height * 0.15)
        appName.zPosition = -1  // Ensure it's behind everything
        
        addChild(background)
        addChild(appName)
    }

    func setupStartButton() {
        let startButton = SKLabelNode(text: "Game Start")
        startButton.name = "startButton"
        startButton.fontName = "Helvetica-Neue"
        startButton.fontSize = 40
        startButton.fontColor = .white
        startButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.3)
        
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
                goToGameStageScene()
            }
        }
    }

    func goToGameStageScene() {
        let gameStageScene = StageScene(size: self.size)
        gameStageScene.scaleMode = .resizeFill
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(gameStageScene, transition: transition)
    }
}

struct LandingContentView: View{
    var scene = LandingScene(size: CGSize(width: 402, height: 874)) // Iphone 16 Pro screen size
    var body: some View{
        VStack{
            SpriteView(scene : scene)
                .ignoresSafeArea()
                .frame(width:402, height:874)
        }
    }
}

//#Preview("LandingContentView")
//{
//    LandingContentView()
//}
