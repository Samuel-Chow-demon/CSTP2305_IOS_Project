//
//  GameScene.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-10.
//

import SpriteKit
import GameplayKit
import SwiftUI
import SwiftUICore
import _SpriteKit_SwiftUI

class GameScene: SKScene {
    
    // get the singleton object
    let gameViewModel = GameViewModel.obj
    let gameScreenViewPort = GameScreenViewPort.obj
    
    // Hero Sprite Node
    var hero : HeroCharacter!
    
    // Drag Controller
    var dragControl : DragController!
    
    // Game Init
    override func didMove(to view: SKView) {
        
        // Setup Scene Size
        self.size = getScreenSize()
        self.backgroundColor = .lightGray
        // use default (0, 0) anchor reference point, bottom left as start
        
        // init Object
        let GAME_OBJ_SIZE = getObjectSize()
        gameViewModel.gameObjectList.removeAll()
        dragControl = gameViewModel.controller
        
        // Load Map And Config Screen
        let arrayMap = LoadMap(from: "map1_grass")
        print(arrayMap!)
        
        print(view.bounds.size)
        print(self.size.width, self.size.height)
        
        let worldRows = arrayMap!.count
        let worldCols = arrayMap![0].count
        let worldHeight = CGFloat(worldRows) * GAME_OBJ_SIZE
        let worldWidth = CGFloat(worldCols) * GAME_OBJ_SIZE
        
        print("world Rows(\(worldRows)), Cols(\(worldCols)), Height(\(worldHeight)), Width(\(worldWidth))")
        
        gameScreenViewPort.currentWorldColRowSize = CGSize(width: CGFloat(worldCols), height:
                                                    CGFloat(worldRows))
        gameScreenViewPort.worldWidthHeight = CGSize(width: worldWidth, height: worldHeight)
        gameScreenViewPort.screenWorldPoint = CGPoint(x: (worldWidth - self.size.width) / 2,
                                                      y: (worldHeight - self.size.height) / 2)
        
        
        print("Screen World Point(\(gameScreenViewPort.screenWorldPoint.x),              \(gameScreenViewPort.screenWorldPoint.y))")
        
        print("Game Obj Size : \(GAME_OBJ_SIZE)")
        
        // ------------------------------------------------------------ Create hero sprite node
        let heroContactBitMask = PhysicsCategory.rock |
                                 PhysicsCategory.tree
        let heroCollideBitMask = PhysicsCategory.rock |
                                 PhysicsCategory.tree
        
        
        hero = HeroCharacter(spriteName: "hero_tokage",
                             objectSize: GAME_OBJ_SIZE,
                             // Always at the center of the screen
                             worldCoord: CGPoint(x: gameScreenViewPort.worldWidthHeight.width / 2,      y:gameScreenViewPort.worldWidthHeight.height / 2),
                             contactBitMask: heroContactBitMask,
                             collisionBitMask: heroCollideBitMask)
        
        // Init hero position at the center of the current screen referenced world point
        hero.spriteNode.position = CGPoint(x: self.size.width / 2,
                                           y: self.size.height / 2)
        
        self.addChild(hero.spriteNode)
        // for arrow move indicator
        self.addChild(hero.triangleBlurNode)
        
        print("hero position : \(hero.spriteNode.position.x), \(hero.spriteNode.position.y)")
        
        
        // ------------------------------------------------------------ Create Grass sprite node (Background)
        let backgroundObjectType = eGameObjType.eGRASS
        
        let grassTexture = loadSpriteSheet(imageName: "grass_tile")

        arrayMap?.enumerated().forEach { (rowIdx, row) in
            row.enumerated().forEach { (colIdx, col) in
                
                let gmObjectBackground = GameObject(texture: grassTexture, objType:         backgroundObjectType,
                                          objectSize: GAME_OBJ_SIZE,
                                          worldRowCol: CGPoint(x: colIdx, y: (worldRows - rowIdx - 1)),
                                          needBody: eGameObjType.eGRASS.needPhysicsBody(),
                                          zPosition : -1) // always at the bottom
                gameViewModel.gameObjectList.append(gmObjectBackground)
                
                // if map design at the spot is not the background type, create the object with the same
                // row col
                if col != backgroundObjectType.rawValue{
                    let objType = eGameObjType(rawValue: col) ?? backgroundObjectType
                    let gmObject = GameObject(spriteName: objType.spriteName, objType: objType,
                                                objectSize: GAME_OBJ_SIZE,
                                                worldRowCol: CGPoint(x: colIdx, y: (worldRows - rowIdx - 1)),
                                                needBody: objType.needPhysicsBody(),
                                                contactBitMask: PhysicsCategory.player,
                                                collisionBitMask: PhysicsCategory.player)
                    gameViewModel.gameObjectList.append(gmObject)
                }
            }
        }
        
        // Add All Object to screen as child
        gameViewModel.gameObjectList.forEach {
            self.addChild($0.spriteNode)
        }
        
        // ------------------------------------------------------------ Define Drag Control
        dragControl.onDragBegan = { startCGPoint in
            self.hero.dragStartPosition = startCGPoint
            print("Drag Start : \(startCGPoint)")
        }
        dragControl.onDragChanged = { angle, dy, dx in
            
            // prevent drag began skipped
            if (self.hero.dragStartPosition == nil)
            {
                return
            }
            
            // Calculate the delta based on the angle and default speed
            let deltaX = cos(angle) * CGFloat(Constant.DEFAULT_HERO_SPEED)
            let deltaY = sin(angle) * CGFloat(Constant.DEFAULT_HERO_SPEED)
            
            self.hero.isDragging = true
            
            self.hero.updateTextureForDirection(angle)
            self.hero.triangleNode.path = DragArrowPath(in: self.frame, angle: angle).cgPath
            self.hero.triangleNode.position = self.hero.dragStartPosition ?? CGPoint(x:0,y:0)
            
            print("Delta X : \(deltaX), Delta Y : \(deltaY)")
            print("Dragging, angle : \(angle), dy : \(dy), dx : \(dx), direction : \(self.hero.eCurDir)")
            //print("Triangle pos: \(self.hero.triangleNode.position)")
            
            // Need to setup a future position physics body to see if any future collision occur
            // Simulate future position
            let futurePosition = CGPoint(x: self.hero.spriteNode.position.x + deltaX,
                                         y: self.hero.spriteNode.position.y + deltaY)
            
            // Check for potential collisions
            var willCollide = false
            
            self.enumerateChildNodes(withName: Constant.SPRITE_NODE_COLLIDABLE) { node, _ in
                
                //print("node Block, \(node.frame)")
                
                if node.physicsBody == nil { return }

                // Manually check if the future position intersects with any other physics body
                let nodeRect = node.frame
                let futureRect = CGRect(x: futurePosition.x - self.hero.spriteNode.size.width / 2 + Constant.CHARACTER_MOVE_COLLIDER_BUFFER,
                                        y: futurePosition.y - self.hero.spriteNode.size.height / 2 - Constant.CHARACTER_MOVE_COLLIDER_BUFFER,
                                        width: self.hero.spriteNode.size.width - Constant.CHARACTER_MOVE_COLLIDER_BUFFER,
                                        height: self.hero.spriteNode.size.height - Constant.CHARACTER_MOVE_COLLIDER_BUFFER)
                
                //print("future Block, \(futureRect)")
                if futureRect.intersects(nodeRect) {
                    willCollide = true
                }
                
            }
            
            if (willCollide)
            {
                //print("Block")
                return
            }
            
            //self.hero.spriteNode.position.x += deltaX
            //self.hero.spriteNode.position.y += deltaY
            
            self.gameScreenViewPort.updateScreenWorldPoint(delta : CGPoint(x: deltaX, y: deltaY))
            let centerOfScreen = self.gameScreenViewPort.getCenterOfTheScreen()
            self.hero.spriteNode.position.x = centerOfScreen.x - self.gameScreenViewPort.screenWorldPoint.x
            self.hero.spriteNode.position.y = centerOfScreen.y - self.gameScreenViewPort.screenWorldPoint.y
            
            print("hero position, \(self.hero.spriteNode.position.x), \(self.hero.spriteNode.position.y)")
            
//            let moveAction = SKAction.move(to: CGPoint(x: self.hero.spriteNode.position.x + deltaX,
//                                                       y: self.hero.spriteNode.position.y + deltaY), duration: 0.016)
//            self.hero.spriteNode.run(moveAction)
        }
        dragControl.onDragEnded = {
            self.hero.dragStartPosition = nil
            self.hero.isDragging = false
            print("Drag End")
        }
        
        // Add gesture recognizer
        let dragGesture = UIPanGestureRecognizer(target: dragControl, action: #selector(dragControl.HandleDrag(_:)))
        view.addGestureRecognizer(dragGesture)

    }
    
    
    
    // Game Loop Updates
    override func update(_ currentTime: TimeInterval) {
        
        hero.triangleNode.isHidden = !hero.isDragging || hero.dragStartPosition == nil
        
        // Update the render screen when move
        gameViewModel.gameObjectList.forEach{ gameObj in
  
            let needDraw = isSpriteNodeWithinScreen(screen: self.gameScreenViewPort,
                                                    gameObj: gameObj)
            
            if (needDraw)
            {
                let screenWorldX = self.gameScreenViewPort.screenWorldPoint.x
                let screenWorldY = self.gameScreenViewPort.screenWorldPoint.y
                let objWorldX = gameObj.worldCoordPoint.x
                let objWorldY = gameObj.worldCoordPoint.y
                gameObj.spriteNode.position = CGPoint(x:objWorldX - screenWorldX, y:objWorldY - screenWorldY)
            }
            
            gameObj.spriteNode.isHidden = !needDraw
        }
    }
    
    // Game Collision
}

// Create ContentView for preview purpose
struct ContentView: View{
    var scene = GameScene(size: CGSize(width: 402, height: 874)) // Iphone 16 Pro screen size
    var body: some View{
        VStack{
            SpriteView(scene : scene)
                .ignoresSafeArea()
                .frame(width:402, height:874)
        }
    }
}

//#Preview("ContentView")
//{
//    ContentView()
//}
