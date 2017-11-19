//
//  Character.swift
//  SwipeAndPop
//
//  Created by Asher Elgar on 2.10.2017.
//  Copyright © 2017 Asher Elgar. All rights reserved.
//

import SpriteKit
//caterpie, desura, eve, pikachu, sonic, super_mario
enum CharacterType: Int, CustomStringConvertible {
    case unknown = 0, chicken, comic, cow2, african, frog, warrior
    var spriteName: String {
        let spriteNames = [
            "chicken",
            "comic",
            "cow2",
            "african",
            "frog",
            "warrior"]
        
        return spriteNames[rawValue - 1]
    }
    
    var description: String {
        return spriteName
    }
    
    static func random() -> CharacterType {
        return CharacterType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
}

func ==(lhs: Character, rhs: Character) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}

class Character: CustomStringConvertible, Hashable {
    var column: Int
    var row: Int
    let characterType: CharacterType
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, characterType: CharacterType) {
        self.column = column
        self.row = row
        self.characterType = characterType
    }
    
    var description: String {
        return "type:\(characterType) square:(\(column),\(row))"
    }
    
    var hashValue: Int {
        return row * 10 + column
    }
    
}


