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
    
    static let DEFAULT_INTERACT_SIZE_EXTEND_RATIO = CGFloat(1.4375)
    
    static let BACKGROUND_BOTTOM_OFFSET = CGFloat(15) // points
    
    static let DRAG_ARROW_HEIGHT = CGFloat(150)
    static let DRAG_ARROW_WIDTH = CGFloat(30)
    
    static let CHARACTER_MOVE_COLLIDER_BUFFER = CGFloat(5)
    static let SPRITE_NODE_COLLIDABLE = "collidable"
    static let SPRITE_NODE_NON_COLLIDABLE = "nonCollidable"
    
}

// Define the physics categories for collision
struct PhysicsCategory
{
    static let none = 0
    static let player:          UInt32   = 0x1   << 0       // Player category，     0000 0001
    static let playerAttack:    UInt32   = 0x1   << 1       // Player attack,        0000 0010
    static let nonAttackable:   UInt32   = 0x1   << 2       // Non Attackable category， 0000 0100
    static let attackable:      UInt32   = 0x1   << 3       // Attackable category， 0000 0100

}

enum eGameObjType : Int{
    case eGRASS = 0
    case eTREE_BACKGROUND = 1
    case eTREE = 11
    case eROCK = 2
    case eROCK_1 = 21
    
    
    case eCHARACTER = 99
    
    func getPhysicsCAT() -> UInt32{
        switch self
        {
        case .eGRASS, .eROCK, .eTREE, .eTREE_BACKGROUND:
            return PhysicsCategory.nonAttackable
        case .eROCK_1:
            return PhysicsCategory.attackable
        default:
            return PhysicsCategory.player
        }
    }
    
    func needPhysicsBody()->Bool{
        switch self
        {
        case .eCHARACTER, .eTREE, .eTREE_BACKGROUND, .eROCK, .eROCK_1:
            return true
        default:
            return false
        }
    }
    
    func isStatic() -> Bool{
        switch self
        {
        case .eGRASS, .eROCK, .eROCK_1, .eTREE, .eTREE_BACKGROUND:
            return true
        default:
            return false
        }
    }
    
    var spriteName: String{
        switch self
        {
        case .eGRASS: return "grass_tile"
        case .eROCK, .eROCK_1: return "rock1_1"
        case .eTREE, .eTREE_BACKGROUND: return "tree_1"
        default: return ""
        }
    }
    
    var description: String{
        switch self
        {
        case .eCHARACTER: return "character"
        case .eGRASS: return "grass"
        case .eROCK, .eROCK_1: return "rock"
        case .eTREE: return "tree"
        case .eTREE_BACKGROUND: return "tree_background"
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
