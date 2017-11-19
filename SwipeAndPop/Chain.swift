//
//  Chain.swift
//  SwipeAndPop
//
//  Created by Asher Elgar on 6.10.2017.
//  Copyright © 2017 Asher Elgar. All rights reserved.
//

import UIKit

class Chain: Hashable, CustomStringConvertible {
    var characters = [Character]()
    
    var score = 0
    
    enum ChainType: CustomStringConvertible {
        case horizontal
        case vertical
        
        var description: String {
            switch self {
            case .horizontal:
                return "horizontal"
            case .vertical:
                return "vertical"
            }
        }
    }
    
    var chainType: ChainType
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func addCharacter(character: Character) {
        characters.append(character)
    }
    
    func firstCharacter() -> Character {
        return characters[0]
    }
    
    func lastCharacter() -> Character {
        return characters[characters.count - 1]
    }
    
    var length: Int {
        return characters.count
    }
    
    var description: String {
        return "type: \(chainType) characters: \(characters)"
    }
    
    var hashValue: Int {
        return characters.reduce (0) { $0.hashValue ^ $1.hashValue }
    }
    
   
    
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.characters == rhs.characters
}
