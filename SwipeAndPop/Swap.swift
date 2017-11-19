//
//  Swap.swift
//  SwipeAndPop
//
//  Created by Asher Elgar on 3.10.2017.
//  Copyright © 2017 Asher Elgar. All rights reserved.
//


func ==(lhs: Swap, rhs: Swap) -> Bool {
  return (lhs.characterA == rhs.characterA && lhs.characterB == rhs.characterB) ||
    (lhs.characterB == rhs.characterA && lhs.characterA == rhs.characterB)
}

struct Swap: CustomStringConvertible, Hashable {
    let characterA: Character
    let characterB: Character
    
    init(characterA: Character, characterB: Character) {
        self.characterA = characterA
        self.characterB = characterB
    }
    
    var description: String {
        return "swap \(characterA) with \(characterB)"
   }
    
    var hashValue: Int {
        return characterA.hashValue ^ characterB.hashValue
    }
}
