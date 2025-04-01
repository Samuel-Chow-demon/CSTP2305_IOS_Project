//
//  GameScene.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-10.

import SpriteKit
import SwiftUI
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Game-related setup goes here (same as your code)
    let gameViewModel = GameViewModel.obj
    let gameScreenViewPort = GameScreenViewPort.obj
    
    let childNodeAccessLock = NSLock()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.size = getScreenSize()
        self.backgroundColor = .lightGray
        let GAME_OBJ_SIZE = getObjectSize()
        gameViewModel.gameObjectList.removeAll()
        let dragControl = gameViewModel.controller
        let arrayMap = LoadMap(from: "map1_grass")
        
        // Setup map and game objects
        print(view.bounds.size)
        print(self.size.width, self.size.height)
        
        // Setup hero character and background
        var hero = gameViewModel.hero
        if hero == nil {
            let heroContactBitMask = PhysicsCategory.attackable
            let heroCollideBitMask = PhysicsCategory.collidable
            hero = HeroCharacter(eObjectType: .eCHARACTER_1, objectSize: GAME_OBJ_SIZE,
                                 worldCoord: CGPoint(x: gameScreenViewPort.worldWidthHeight.width / 2,
                                                     y: gameScreenViewPort.worldWidthHeight.height / 2),
                                 contactBitMask: heroContactBitMask,
                                 collisionBitMask: heroCollideBitMask)
            gameViewModel.hero = hero
        }
        
        hero?.updatePos(gameScreenViewPort)
        hero?.displayOnOffAttackBox(false)
        hero?.addNodeToScene(self.addChild)
        
        // Background and other game object setup
        let backgroundObjectType = eGameObjType.eGRASS
        let grassTexture = loadSpriteSheet(imageName: "grass_tile")
        arrayMap?.enumerated().forEach { (rowIdx, row) in
            row.enumerated().forEach { (colIdx, col) in
                let gmObjectBackground = GameObject(texture: grassTexture, objType: backgroundObjectType,
                                                     objectSize: GAME_OBJ_SIZE,
                                                     worldRowCol: CGPoint(x: colIdx, y: (worldRows - rowIdx - 1)),
                                                     needBody: eGameObjType.eGRASS.needPhysicsBody(),
                                                     zPosition: -1)
                gameViewModel.gameObjectList.append(gmObjectBackground)
                
                if col != backgroundObjectType.rawValue {
                    let objType = eGameObjType(rawValue: col) ?? backgroundObjectType
                    let gmObject = GameObject(spriteName: objType.spriteName, objType: objType,
                                                objectSize: GAME_OBJ_SIZE,
                                                worldRowCol: CGPoint(x: colIdx, y: (worldRows - rowIdx - 1)),
                                                colliderSizeRatio: objType.colliderRatio(),
                                                needBody: objType.needPhysicsBody(),
                                                contactBitMask: PhysicsCategory.player,
                                                collisionBitMask: PhysicsCategory.player)
                    gmObject.displayOnOffNodeBox(false)
                    gameViewModel.gameObjectList.append(gmObject)
                }
            }
        }
        
        // Add all objects to the scene
        gameViewModel.gameObjectList.forEach {
            $0.addNodeToScene(self.addChild)
        }
        
        // Enemy Factory setup
        gameViewModel.enemyFactory = GameEnemyFactory(objectSize: GAME_OBJ_SIZE,
                                                      maxNumOfEnemy: 30,
                                                      spawnIntervalSecList: [1, 2, 4, 8],
                                                      screenViewPort: gameScreenViewPort)
        
        // Drag control setup
        dragControl.onDragBegan = { startCGPoint in
            hero!.dragStartPosition = startCGPoint
            hero!.circleNode!.isHidden = true
        }
        
        dragControl.onDragChanged = { angle, dy, dx in
            // Handle dragging here...
        }
        
        dragControl.onDragEnded = {
            hero!.dragStartPosition = nil
            hero!.isDragging = false
        }
        
        // Gesture recognizer setup for drag
        let dragGesture = UIPanGestureRecognizer(target: dragControl, action: #selector(dragControl.HandleDrag(_:)))
        view.addGestureRecognizer(dragGesture)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Called when the user touches the screen (touch began)
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            let screenHeight = UIScreen.main.bounds.height
            let currentCGPoint = CGPoint(x: location.x, y: screenHeight - location.y) // flip back to
            //print("Touch began at \(currentCGPoint)")
            
            gameViewModel.hero!.isStartAttack = true
            gameViewModel.hero!.circleNode?.position = currentCGPoint
            gameViewModel.hero!.circleNode?.isHidden = false
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Called when the user lifts their finger off the screen (touch ended)
        if let touch = touches.first {
            //let location = touch.location(in: self.view)
            //print("Touch ended at \(location)")
            
            gameViewModel.hero!.circleNode?.isHidden = true
        }
    }
    
    // Game Loop Updates
    override func update(_ currentTime: TimeInterval)
    {
        gameViewModel.hero!.triangleNode?.isHidden = !(gameViewModel.hero!.isDragging) || gameViewModel.hero!.dragStartPosition == nil
        
        // Update the render screen when move
        gameViewModel.gameObjectList.forEach{ gameObj in
  
            let needDraw = isSpriteNodeWithinScreen(screen: self.gameScreenViewPort,
                                                    gameObj: gameObj)
            
            gameObj.checkIfNeedRenderHandle(self.gameScreenViewPort, needDraw)
        }
        
        gameViewModel.hero!.handleAttackSprite()
        
        // Here for enemy handle
        gameViewModel.enemyFactory?.checkAndSpawnEnemy(enemies: &gameViewModel.enemies, eObjectType: eGameObjType.eENEMY_1, addChild: self.addChild, accessNodeLock : childNodeAccessLock)
        
        gameViewModel.enemies.forEach{ enemy in
            
            if (!enemy.isDie())
            {
                enemy.MoveTowardsHero(viewport : self.gameScreenViewPort,
                                      heroPos : gameViewModel.hero!.worldCoordPoint)
            }
            
            if (enemy.handleGetHarmResponse() == true)
            {
                enemy.RepelMove(viewport: self.gameScreenViewPort)
            }
            
            // if after kill, remove from the scene
            self.checkAndRemoveEnemyNode(enemy : enemy)
        }
        
        gameViewModel.colliderManager.checkAndHandleCollides()
        
        if (gameViewModel.hero!.handleGetHarmResponse() == true)
        {
            gameViewModel.hero!.HeroRepelMove(viewport: self.gameScreenViewPort,
                                              beforeMoveCheckIsBlock: beforeMoveCheckIsBlocked)
        }
        
        gameViewModel.colliderManager.checkAndRemoveRegistry()
    }
    
    // Game Collision
    func didBegin(_ contact: SKPhysicsContact)
    {
        // Get the two bodies involved in the contact
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if let spriteNodeA = bodyA.node as? SKSpriteNode,
           let spriteNodeB = bodyB.node as? SKSpriteNode
        {
            gameViewModel.colliderManager.registerCollision(spriteNodeA, spriteNodeB)
        }
    }
    
    // Some time the engine would optimize the escape contact by only destruct the
    // first pair of contact when separate, thus we need to manual call
    // gameViewModel.colliderManager.checkAndRemoveRegistry() to unregister the pair
    func didEnd(_ contact: SKPhysicsContact) {
        // Get the two bodies involved in the contact
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if let spriteNodeA = bodyA.node as? SKSpriteNode,
           let spriteNodeB = bodyB.node as? SKSpriteNode
        {
            gameViewModel.colliderManager.unRegisterCollision(spriteNodeA, spriteNodeB)
        }
    }
}

// Create ContentView for preview purpose
struct ContentView: View{
    @State private var scene = GameScene(size: CGSize(width: 402, height: 874))// Iphone 16 Pro screen size
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
