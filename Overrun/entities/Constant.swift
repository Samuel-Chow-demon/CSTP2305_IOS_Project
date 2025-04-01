//
//  Constant.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-10.
//

import Foundation

struct Constant{
    
    static let SCREEN_TILE_COL = 7
    static let SCREEN_TILE_ROW = 15
    
    static let DEFAULT_LIVES = 3
    static let DEFAULT_HERO_SPEED = 10
    static let DEFAULT_HERO_HARM_REPEL_DISTANCE = CGFloat(50)
    
    static let DEFAULT_INTERACT_SIZE_EXTEND_RATIO = CGFloat(1.4375)
    
    static let BACKGROUND_BOTTOM_OFFSET = CGFloat(15) // points
    
    static let DRAG_ARROW_HEIGHT = CGFloat(150)
    static let DRAG_ARROW_WIDTH = CGFloat(30)
    
    static let CHARACTER_MOVE_COLLIDER_BUFFER = CGFloat(5)
    static let SPRITE_NODE_COLLIDABLE = "collidable"
    static let SPRITE_NODE_NON_COLLIDABLE = "nonCollidable"
    
    static let USER_FLAG_ID = "id"
    static let USER_FLAG_GET_HARM = "harm"
    static let USER_FLAG_IS_ATTACKING = "isAttacking"
    static let USER_FLAG_IS_INVINCIBLE = "invincible"
    
}

// Define the physics categories for collision
struct PhysicsCategory
{
    static let none = 0
    static let player:          UInt32   = 0x1   << 0       // Player category，     0000 0001
    static let playerAttack:    UInt32   = 0x1   << 1       // Player attack,        0000 0010
    static let nonAttackable:   UInt32   = 0x1   << 2       // Non Attackable category， 0000 0100
    static let attackable:      UInt32   = 0x1   << 3       // Attackable category， 0000 1000
    static let collidable:      UInt32   = 0x1   << 4       // for collide,          0001 0000
    static let harmful:         UInt32   = 0x1   << 5       // harmful category,     0010 0000

}

enum eGameObjType : Int{
    case eGRASS = 0
    case eTREE_BACKGROUND = 1
    case eTREE = 11
    
    case eROCK = 2
    case eROCK_1 = 21
    case eROCK_TOXIC = 22
    case eROCK_2 = 23
    
    case eSAND = 5
    
    case eCACTUS = 6
    
    case eENEMY = 98
    case eCHARACTER = 99
    
    func getPhysicsCAT() -> UInt32{
        switch self
        {
        case .eGRASS, .eSAND,
             .eROCK, .eROCK_2,
             .eTREE, .eTREE_BACKGROUND:
            return PhysicsCategory.nonAttackable
        case .eROCK_1:
            return PhysicsCategory.attackable
        case .eROCK_TOXIC, .eCACTUS, .eENEMY:
            return PhysicsCategory.attackable | PhysicsCategory.harmful
        default:
            return 0
        }
    }
    
    func needPhysicsBody()->Bool{
        switch self
        {
        case .eCHARACTER, .eTREE,
              .eROCK, .eROCK_1, .eROCK_TOXIC, .eROCK_2,
              .eCACTUS,
              .eENEMY:
            return true
        default:
            return false
        }
    }
    
    func colliderRatio()->CGFloat{
        switch self
        {
        case .eTREE:
            return 0.8
        case .eROCK, .eROCK_1, .eROCK_TOXIC, .eROCK_2:
            return 0.8
        case .eCACTUS:
            return 0.8
            
        default:
            return 1.0 // the same size as the sprite texture
        }
    }
    
    func isStatic() -> Bool{
        switch self
        {
        case .eGRASS, .eSAND,
             .eROCK, .eROCK_1, .eROCK_2, .eROCK_TOXIC,
             .eTREE, .eTREE_BACKGROUND,
             .eCACTUS:
            return true
        default:
            return false
        }
    }
    
    var spriteName: String{
        switch self
        {
        case .eGRASS: return "grass_tile"
        case .eSAND: return "sand_1"
        case .eROCK, .eROCK_1: return "rock1_1"
        case .eROCK_2: return "rock2_1"
        case .eROCK_TOXIC: return "rock3_toxic"
        case .eTREE, .eTREE_BACKGROUND: return "tree_1"
        case .eCACTUS: return "cactus_1"
        case .eENEMY: return "enemy"
        default: return ""
        }
    }
    
    var description: String{
        switch self
        {
        case .eCHARACTER: return "character"
        case .eGRASS: return "grass"
        case .eROCK, .eROCK_1, .eROCK_2, .eROCK_TOXIC: return "rock"
        case .eTREE: return "tree"
        case .eTREE_BACKGROUND: return "tree_background"
        case .eSAND: return "sand"
        case .eCACTUS: return "cactus"
        case .eENEMY: return "enemy"
        }
    }
}

// follow the sprite sheet starting from bottom to top
enum eDirection: Int{
    case eRIGHT = 0
    case eLEFT
    case eUP
    case eDOWN
}
