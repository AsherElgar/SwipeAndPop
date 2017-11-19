//
//  Level.swift
//  SwipeAndPop
//
//  Created by Asher Elgar on 2.10.2017.
//  Copyright © 2017 Asher Elgar. All rights reserved.
//

import UIKit


let NumColumns = 9
let NumRows = 9
let NumLevels = 5 // Excluding Level_0.json

class Level {

  // MARK: Properties

  fileprivate var characters = ArrayGrid<Character>(columns: NumColumns, rows: NumRows)

  fileprivate var tiles = ArrayGrid<Tile>(columns: NumColumns, rows: NumRows)


  fileprivate var possibleSwaps = Set<Swap>()

  var targetScore = 0
  var maximumMoves = 0


  fileprivate var comboMultiplier = 0


  // MARK: Initialization

  // Create a level by loading it from a file.
  init(filename: String) {
    guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename) else { return }

    guard let tilesArray = dictionary["tiles"] as? [[Int]] else { return }

    // Loop through the rows...
    for (row, rowArray) in tilesArray.enumerated() {

      let tileRow = NumRows - row - 1

      for (column, value) in rowArray.enumerated() {
        if value == 1 {
          tiles[column, tileRow] = Tile()
        }
      }
    }

    targetScore = dictionary["targetScore"] as! Int
    maximumMoves = dictionary["moves"] as! Int
  }


  // MARK: Level Setup

  func shuffle() -> Set<Character> {
    var set: Set<Character>
    repeat {
      set = createInitialCharacters()
    
      detectPossibleSwaps()

    } while possibleSwaps.count == 0

    return set
  }

  fileprivate func createInitialCharacters() -> Set<Character> {
    var set = Set<Character>()

    for row in 0..<NumRows {
      for column in 0..<NumColumns {

        if tiles[column, row] != nil {
          var characterType: CharacterType
          repeat {
            characterType = CharacterType.random()
          } while
            (column >= 2 &&
              characters[column - 1, row]?.characterType == characterType &&
              characters[column - 2, row]?.characterType == characterType) ||
            (row >= 2 &&
              characters[column, row - 1]?.characterType == characterType &&
              characters[column, row - 2]?.characterType == characterType)

            let character = Character(column: column, row: row, characterType: characterType)
          characters[column, row] = character

          set.insert(character)
        }
      }
    }
    return set
  }


  // MARK: Query the level

  func tileAt(column: Int, row: Int) -> Tile? {
    assert(column >= 0 && column < NumColumns)
    assert(row >= 0 && row < NumRows)
    return tiles[column, row]
  }

  func characterAt(column: Int, row: Int) -> Character? {
    assert(column >= 0 && column < NumColumns)
    assert(row >= 0 && row < NumRows)
    return characters[column, row]
  }

  
  func isPossibleSwap(_ swap: Swap) -> Bool {
    return possibleSwaps.contains(swap)
  }

  fileprivate func hasChainAt(column: Int, row: Int) -> Bool {
    let characterType = characters[column, row]!.characterType

    // Horizontal chain check
    var horzLength = 1

    // Left
    var i = column - 1
    
    while i >= 0 && characters[i, row]?.characterType == characterType {
      i -= 1
      horzLength += 1
    }

    // Right
    i = column + 1
    while i < NumColumns && characters[i, row]?.characterType == characterType {
      i += 1
      horzLength += 1
    }
    if horzLength >= 3 { return true }

    // Vertical chain check
    var vertLength = 1

    // Down
    i = row - 1
    while i >= 0 && characters[column, i]?.characterType == characterType {
      i -= 1
      vertLength += 1
    }

    // Up
    i = row + 1
    while i < NumRows && characters[column, i]?.characterType == characterType {
      i += 1
      vertLength += 1
    }
    return vertLength >= 3
  }


  // MARK: Swapping

  func performSwap(_ swap: Swap) {

    let columnA = swap.characterA.column
    let rowA = swap.characterA.row
    let columnB = swap.characterB.column
    let rowB = swap.characterB.row

    characters[columnA, rowA] = swap.characterB
    swap.characterB.column = columnA
    swap.characterB.row = rowA

    characters[columnB, rowB] = swap.characterA
    swap.characterA.column = columnB
    swap.characterA.row = rowB
  }


  func detectPossibleSwaps() {
    var set = Set<Swap>()

    for row in 0..<NumRows {
      for column in 0..<NumColumns {
        if let character = characters[column, row] {

          if column < NumColumns - 1 {

            if let other = characters[column + 1, row] {
              // Swap them
              characters[column, row] = other
              characters[column + 1, row] = character

              if hasChainAt(column: column + 1, row: row) ||
                hasChainAt(column: column, row: row) {
                set.insert(Swap(characterA: character, characterB: other))
              }

              // Swap them back
              characters[column, row] = character
              characters[column + 1, row] = other
            }
          }

          if row < NumRows - 1 {

            if let other = characters[column, row + 1] {
              // Swap them
              characters[column, row] = other
              characters[column, row + 1] = character

              if hasChainAt(column: column, row: row + 1) ||
                hasChainAt(column: column, row: row) {
                set.insert(Swap(characterA: character, characterB: other))
              }

              // Swap them back
              characters[column, row] = character
              characters[column, row + 1] = other
            }
          }
        }
      }
    }

    possibleSwaps = set
  }

  fileprivate func calculateScores(for chains: Set<Chain>) {
    // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
    for chain in chains {
      chain.score = 60 * (chain.length - 2) * comboMultiplier
      comboMultiplier += 1
    }
  }

  // Should be called at the start of every new turn.
  func resetComboMultiplier() {
    comboMultiplier = 1
  }


  // MARK: Detecting Matches

  fileprivate func detectHorizontalMatches() -> Set<Chain> {
    var set = Set<Chain>()

    for row in 0..<NumRows {
      // Don't need to look at last two columns.
      var column = 0
      while column < NumColumns-2 {
        if let character = characters[column, row] {
          let matchType = character.characterType

          if characters[column + 1, row]?.characterType == matchType &&
             characters[column + 2, row]?.characterType == matchType {

            let chain = Chain(chainType: .horizontal)
            repeat {
                chain.addCharacter(character: characters[column, row]!)
              
              column += 1
            } while column < NumColumns && characters[column, row]?.characterType == matchType

            set.insert(chain)
            continue
          }
        }

        column += 1
      }
    }
    return set
  }

  // Same as the horizontal version but steps through the array differently.
  fileprivate func detectVerticalMatches() -> Set<Chain> {
    var set = Set<Chain>()

    for column in 0..<NumColumns {
      var row = 0
      while row < NumRows-2 {
        if let character = characters[column, row] {
          let matchType = character.characterType

          if characters[column, row + 1]?.characterType == matchType &&
            characters[column, row + 2]?.characterType == matchType {

            let chain = Chain(chainType: .vertical)
            repeat {
                chain.addCharacter(character: characters[column, row]!)
              row += 1
            } while row < NumRows && characters[column, row]?.characterType == matchType

            set.insert(chain)
            continue
          }
        }
        row += 1
      }
    }
    return set
  }

 
  func removeMatches() -> Set<Chain> {
    let horizontalChains = detectHorizontalMatches()
    let verticalChains = detectVerticalMatches()

 

    removeCharacter(horizontalChains)
    removeCharacter(verticalChains)

    calculateScores(for: horizontalChains)
    calculateScores(for: verticalChains)

    return horizontalChains.union(verticalChains)
  }

  fileprivate func removeCharacter(_ chains: Set<Chain>) {
    for chain in chains {
      for character in chain.characters {
        characters[character.column, character.row] = nil
      }
    }
  }


  // MARK: Detecting Holes

  func fillHoles() -> [[Character]] {
    var columns = [[Character]]()

   
    for column in 0..<NumColumns {
      var array = [Character]()
      for row in 0..<NumRows {

        
        if tiles[column, row] != nil && characters[column, row] == nil {

     
          for lookup in (row + 1)..<NumRows {
            if let character = characters[column, lookup] {
              
              characters[column, lookup] = nil
              characters[column, row] = character
              character.row = row

              array.append(character)

             
              break
            }
          }
        }
      }

      if !array.isEmpty {
        columns.append(array)
      }
    }
    return columns
  }

  func topUpCharacters() -> [[Character]] {
    var columns = [[Character]]()
    var characterType: CharacterType = .unknown

    for column in 0..<NumColumns {
      var array = [Character]()

      
      var row = NumRows - 1
      while row >= 0 && characters[column, row] == nil {
      
        if tiles[column, row] != nil {

          var newCharacterType: CharacterType
          repeat {
            newCharacterType = CharacterType.random()
          } while newCharacterType == characterType
          characterType = newCharacterType

            let character = Character(column: column, row: row, characterType: characterType)
          characters[column, row] = character
          array.append(character)
        }

        row -= 1
      }

      if !array.isEmpty {
        columns.append(array)
      }
    }
    return columns
  }

//    (tiles[column, row] != nil && tiles[column + 2, row] != nil && tiles[column + 1, row] != nil && tiles[column + 3, row] != nil) && column + 3 <= NumColumns
    
    //MARK: check hints...
    
     func checkForHintHorizontalMatches() -> Set<Chain> {
       
        var set = Set<Chain>()
        
        for row in 0..<NumRows {
            // Don't need to look at last two columns.
            var column = 0
            while column < NumColumns{
                if tiles[column, row] != nil{
                    if let character = characters[column, row] {
                        let matchType = character.characterType
                        let character1 = characters[column + 1, row]?.characterType
                        let character2 = characters[column + 2, row]?.characterType
                        let character3 = characters[column + 3, row]?.characterType
                        
                        if (character1 == matchType || character2 == matchType) &&
                            character3 == matchType {
                            
                            print("Horizontal Hint!!! 🤑 (\(matchType) -- \(column,row) )>>(\(String(describing: character1)) >>\(column + 1,row))<< -- (\(String(describing: character2)) >>\(column + 2,row)) --( \(String(describing: character3)) >>\(column + 3,row))" )
                            
                            let chain = Chain(chainType: .horizontal)
                            repeat {
                                chain.addCharacter(character: characters[column, row]!)
                                
                                column += 1
                            } while column < NumColumns && characters[column, row]?.characterType == matchType
                            
                            set.insert(chain)
                            continue
                        }
                    }
                    
                    
                }
                
                column += 1
                
            }
        }
        if set.isEmpty{
            print("need to shuffle 😎 --->>>")
            
        }
        return set
    
}
    
    
    func checkForHintVerticalMatches() -> Set<Chain> {
        
        var set = Set<Chain>()
        
        for column in 0..<NumColumns {
            // Don't need to look at last two columns.
            var row = 0
            while row < NumRows-2{
                if tiles[column, row] != nil{
                if let character = characters[column, row] {
                    let matchType = character.characterType
                    let character1 = characters[column, row + 1]?.characterType
                    let character2 = characters[column, row + 2]?.characterType
                    let character3 = characters[column, row + 3]?.characterType
                    
                    if (character1 == matchType || character2 == matchType) &&
                        character3 == matchType {
                        
                        print("Vertical Hint!!! 🤑 \(matchType) >>\(column,row) >>\(String(describing: character1))--\(column,row + 1)<< -- \(String(describing: character2)) >>\(column,row + 2) -- \(String(describing: character3)) >>\(column,row + 3)" )
                        
                        let chain = Chain(chainType: .vertical)
                        repeat {
                            chain.addCharacter(character: characters[column, row]!)
                            
                            row += 1
                        } while row < NumRows && characters[column, row]?.characterType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }
                
                
            }
                
                row += 1
                
            }
        }
        if set.isEmpty{
                print("need to shuffle 😎 --->>>")
            
        }
        return set
    }
    
    func checkForHintVHlMatches() -> Set<Chain> {
        
        var set = Set<Chain>()
        
        for column in 0..<NumColumns {
            // Don't need to look at last two columns.
            var row = 0
            while row < NumRows{
                if tiles[column, row] != nil{
                    if let character = characters[column, row] {
                        let matchType = character.characterType
                        let character1 = characters[column, row + 1]?.characterType
                        let character2 = characters[column, row + 2]?.characterType
                        let character3 = characters[column, row + 3]?.characterType
                       
                        let character1Up = characters[column + 1, row + 1]?.characterType
                        let character2Up = characters[column + 2, row + 1]?.characterType
                        let character3Up = characters[column + 3, row + 1]?.characterType
                       
                        let character1Down = characters[column + 1, row - 1]?.characterType
                        let character2Down = characters[column + 2, row - 1]?.characterType
                        let character3Down = characters[column + 3, row - 1]?.characterType
                       
                        let chain = Chain(chainType: .vertical)
                        
                        if (character1 == matchType || character2 == matchType || character3 == matchType){
                            if character1 == matchType && character2 == matchType{
                                if character3Up == matchType && characters.rows + 1 < NumRows && characters.columns + 3 < NumColumns{
                                    chain.addCharacter(character: characters[column, row]!)
                                    chain.addCharacter(character: characters[column, row + 1]!)
                                    chain.addCharacter(character: characters[column, row + 2]!)
                                    chain.addCharacter(character: characters[column + 3, row + 1]!)
                                    set.insert(chain)
                                    print("🤡 3 Hint Up --> \(String(describing: character3Up)) >> \(column + 3, row + 1) >>>\(set)")
                                }else if character3Down == matchType && row > 0 && column < NumColumns{
                                    chain.addCharacter(character: characters[column, row]!)
                                    chain.addCharacter(character: characters[column, row + 1]!)
                                    chain.addCharacter(character: characters[column, row + 2]!)
                                    chain.addCharacter(character: characters[column + 3, row - 1]!)
                                    set.insert(chain)
                                    print("🤡 3 Hint Down --> \(String(describing: character3Down))>> \(column + 3, row - 1) >>>\(set)")
                                }
                            }else if character1 == matchType && character3 == matchType{
                                if character2Up == matchType && row < NumRows && column < NumColumns{
                                    chain.addCharacter(character: characters[column, row]!)
                                    chain.addCharacter(character: characters[column, row + 1]!)
                                    chain.addCharacter(character: characters[column, row + 3]!)
                                    chain.addCharacter(character: characters[column + 2, row + 1]!)
                                    set.insert(chain)
                                    print("🤡 2 Hint Up --> \(String(describing: character2Up)) >> \(column + 2, row + 1) >>>\(set)")
                                }else if character2Down == matchType && row > 0 && column < NumColumns{
                                    chain.addCharacter(character: characters[column, row]!)
                                    chain.addCharacter(character: characters[column, row + 1]!)
                                    chain.addCharacter(character: characters[column, row + 3]!)
                                    chain.addCharacter(character: characters[column + 2, row - 1]!)
                                    set.insert(chain)
                                    print("🤡 2 Hint Down --> \(String(describing: character2Down)) >> \(column + 2, row - 1) >>>\(set)")
                                }
                                
                            }else if character2 == matchType && character3 == matchType{
                                if character1Up == matchType && row < NumRows && column < NumColumns{
                                    chain.addCharacter(character: characters[column, row]!)
                                    chain.addCharacter(character: characters[column, row + 2]!)
                                    chain.addCharacter(character: characters[column, row + 3]!)
                                    chain.addCharacter(character: characters[column + 1, row + 1]!)
                                    set.insert(chain)
                                    print("🤡 1 Hint Up --> \(String(describing: character1Up)) >> \(column + 1, row + 1) >>>\(set)")
                                }else if character1Down == matchType && row > 0 && column < NumColumns{
                                    chain.addCharacter(character: characters[column, row]!)
                                    chain.addCharacter(character: characters[column, row + 2]!)
                                    chain.addCharacter(character: characters[column, row + 3]!)
                                    chain.addCharacter(character: characters[column + 1, row - 1]!)
                                    set.insert(chain)
                                    print("🤡 1 Hint Down --> \(String(describing: character1Down)) >> \(column + 3, row + 1) >>>\(set)")
                                }
                            }
                     
                            print("UP-DOWN Hint!!! 🤑 \(matchType) >>\(column,row) >>\(String(describing: character1))--\(column,row + 1)<< -- \(String(describing: character2)) >>\(column,row + 2) -- \(String(describing: character3)) >>\(column,row + 3)" )
                            
                             // let chain = Chain(chainType: .vertical)
                            repeat {
                                //chain.addCharacter(character: characters[column, row]!)

                                row += 1
                            } while row < NumRows && characters[column, row]?.characterType == matchType

                            
                            set.insert(chain)
                            continue
                        }
                    }
                    
                    
                }
                
                row += 1
                
            }
        }
        if set.isEmpty{
            print("VH need to shuffle 😎 --->>>")

        }
        return set
    }
}


