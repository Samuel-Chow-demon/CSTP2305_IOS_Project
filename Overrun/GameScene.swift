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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // get the singleton object
    let gameViewModel = GameViewModel.obj
    let gameScreenViewPort = GameScreenViewPort.obj
    
    let childNodeAccessLock = NSLock()
    
    // Game Init
    override func didMove(to view: SKView) {
        
        // Setup package
        physicsWorld.contactDelegate = self
        
        // Setup Scene Size
        self.size = getScreenSize()
        self.backgroundColor = .lightGray
        // use default (0, 0) anchor reference point, bottom left as start
        
        // init Object
        let GAME_OBJ_SIZE = getObjectSize()
        gameViewModel.gameObjectList.removeAll()
        let dragControl = gameViewModel.controller
        
        // Load Map And Config Screen
        let arrayMap = LoadMap(from: "map1_grass")
//        print(arrayMap!)
        
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
        var hero = gameViewModel.hero
        if (hero == nil)
        {
            let heroContactBitMask = PhysicsCategory.attackable
            let heroCollideBitMask = PhysicsCategory.collidable
            
            hero = HeroCharacter(eObjectType : eGameObjType.eCHARACTER_1,
                                 objectSize: GAME_OBJ_SIZE,
                                 // Always at the center of the screen
                                 worldCoord: CGPoint(x: gameScreenViewPort.worldWidthHeight.width / 2,      y:gameScreenViewPort.worldWidthHeight.height / 2),
                                 contactBitMask: heroContactBitMask,
                                 collisionBitMask: heroCollideBitMask)
            
            // Pointing the gameViewModel.hero to the same created object
            gameViewModel.hero = hero
        }
        
        // Init hero position at the center of the current screen referenced world point
        hero!.updatePos(gameScreenViewPort)
        
        hero!.displayOnOffAttackBox(false)
        
        hero!.addNodeToScene(self.addChild)

        print("hero position : \(hero!.spriteNode.position.x), \(hero!.spriteNode.position.y)")
        
        
        // ------------------------------------------------------------ Create Grass sprite node (Background)
        let backgroundObjectType = eGameObjType.eGRASS
        
        let grassTexture = loadSpriteSheet(imageName: "grass_tile")

        arrayMap?.enumerated().forEach { (rowIdx, row) in
            row.enumerated().forEach { (colIdx, col) in
                
                let gmObjectBackground = GameObject(texture: grassTexture, objType:                 backgroundObjectType,
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
                                                colliderSizeRatio: objType.colliderRatio(),
                                                needBody: objType.needPhysicsBody(),
                                                contactBitMask: PhysicsCategory.player,
                                                collisionBitMask: PhysicsCategory.player)
                    
                    gmObject.displayOnOffNodeBox(false)
                    
                    gameViewModel.gameObjectList.append(gmObject)
                }
            }
        }
        
        // Add All Object to screen as child
        gameViewModel.gameObjectList.forEach {
            
            $0.addNodeToScene(self.addChild)
            //self.addChild($0.spriteNode)
        }
        
        // ------------------------------------------------------------ Enemy Factory
        let maxNumOfEnemy : UInt8 = 30
        
        gameViewModel.enemyFactory = GameEnemyFactory(objectSize: GAME_OBJ_SIZE,
                                    maxNumOfEnemy : maxNumOfEnemy,
                                    spawnIntervalSecList : [1, 2, 4, 8],
                                    screenViewPort : gameScreenViewPort)
        
        
        
        
        // ------------------------------------------------------------ Define Drag Control
        dragControl.onDragBegan = { startCGPoint in
            hero!.dragStartPosition = startCGPoint
            hero!.circleNode!.isHidden = true
            print("Drag Start : \(startCGPoint)")
        }
        dragControl.onDragChanged = { angle, dy, dx in
            
            // prevent drag began skipped
            if (hero!.dragStartPosition == nil)
            {
                return
            }
            
            // Calculate the delta based on the angle and default speed
            let deltaX = cos(angle) * hero!.objectSpeed
            let deltaY = sin(angle) * hero!.objectSpeed
            
            hero!.isDragging = true
            
            hero!.updateTextureForDirection(angle)
            hero!.triangleNode!.path = DragArrowPath(in: self.frame, angle: angle).cgPath
            hero!.triangleNode!.position = hero!.dragStartPosition ?? CGPoint(x:0,y:0)
            
            print("Delta X : \(deltaX), Delta Y : \(deltaY)")
            print("Dragging, angle : \(angle), dy : \(dy), dx : \(dx), direction : \(hero!.eCurDir)")
            //print("Triangle pos: \(self.hero.triangleNode.position)")
            
            // Need to setup a future position physics body to see if any future collision occur
            // Simulate future position
            let futurePosition = CGPoint(x: hero!.spriteNode.position.x + deltaX,
                                         y: hero!.spriteNode.position.y + deltaY)
            
            // Check for potential collisions
            if (self.beforeMoveCheckIsBlocked(futurePosition : futurePosition,
                                              objectSize: hero!.spriteNode.size,
                                              colliderBuffer: Constant.CHARACTER_MOVE_COLLIDER_BUFFER))
            {
                return
            }
            
            // would update the gameScreenViewPort
            hero!.HeroMove(viewport: self.gameScreenViewPort,
                       delta : CGPoint(x: deltaX, y: deltaY))
            
            print("hero position, \(hero!.spriteNode.position.x), \(hero!.spriteNode.position.y)")
            
        }
        dragControl.onDragEnded = {
            hero!.dragStartPosition = nil
            hero!.isDragging = false
            print("Drag End")
        }
        
        // Add gesture recognizer
        // For Drag
        let dragGesture = UIPanGestureRecognizer(target: dragControl, action: #selector(dragControl.HandleDrag(_:)))
        view.addGestureRecognizer(dragGesture)
    
    }
    
    func beforeMoveCheckIsBlocked(futurePosition : CGPoint,
                                  objectSize : CGSize,
                                  colliderBuffer : CGFloat) -> Bool
    {
        var willCollide = false
            
        self.childNodeAccessLock.lock()
        
        self.enumerateChildNodes(withName: Constant.SPRITE_NODE_COLLIDABLE) { node, _ in
 
            //print("node Block, \(node.frame)")
            
            if (node.physicsBody == nil)
            {
                return
            }
            
            if node.frame.isNull || node.frame.isInfinite {
                print("Invalid node frame detected: \(node)")
                return
            }
            
            // Manually check if the future position intersects with any other physics body
            let nodeRect = node.frame
            
            // CGRect start from bottom-left corner
            let futureRect = CGRect(x: futurePosition.x - objectSize.width / 2 +                                 colliderBuffer,
                                    y: futurePosition.y - objectSize.height / 2 +
                                    colliderBuffer,
                                    width: objectSize.width -                                colliderBuffer,
                                    height: objectSize.height -
                                    colliderBuffer)
            
            if (isCollided(futureRect, nodeRect))
            {
                //print("collided")
                willCollide = true
            }
        }
        self.childNodeAccessLock.unlock()
        
        return willCollide
    }
    
    func checkAndRemoveEnemyNode(enemy: EnemyCharacter)
    {
        if (enemy.spriteNode.isHidden)
        {
            self.childNodeAccessLock.lock()
            enemy.spriteNode.removeFromParent()
            
            self.childNodeAccessLock.unlock()
        }
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
