//
//  GameScene.swift
//  SwipeAndPop
//
//  Created by Asher Elgar on 2.10.2017.
//  Copyright © 2017 Asher Elgar. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    var level: Level!
    
    var TileWidth: CGFloat = 38.0
    var TileHeight: CGFloat = 38.0
    
    let gameLayer = SKNode()
    let characterLayer = SKNode()
    let tilesLayer = SKNode()
    let cropLayer = SKCropNode()
    let maskLayer = SKNode()
    
    
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    
   
    var swipeHandler: ((Swap) -> ())?
    
    var selectionSprite = SKSpriteNode()
    
    let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
    let fallingCharacterSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
    let addCharacterSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
    
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        if screenWidth < 325{
            self.TileWidth = 33.0
            self.TileHeight = 33.0
        }
        print("### --> width: \(screenWidth) height: \(screenHeight)")
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Put an image on the background. Because the scene's anchorPoint is
        // (0.5, 0.5), the background image will always be centered on the screen.
        let background = SKSpriteNode(imageNamed: "jungle")
        background.size = size
        addChild(background)
        
        // Add a new node that is the container for all other layers on the playing
        // field. This gameLayer is also centered in the screen.
        gameLayer.isHidden = true
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
    
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
    
        gameLayer.addChild(cropLayer)
        
        maskLayer.position = layerPosition
        cropLayer.maskNode = maskLayer
        
     
        characterLayer.position = layerPosition
        cropLayer.addChild(characterLayer)
        
        swipeFromColumn = nil
        swipeFromRow = nil
        
        let _ = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
    }
    
    
    // MARK: Level Setup
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                // If there is a tile at this position, then create a new tile
                // sprite and add it to the mask layer.
                if level.tileAt(column: column, row: row) != nil {
                    let tileNode = SKSpriteNode(imageNamed: "whiteBox")
                    tileNode.size = CGSize(width: TileWidth + 2, height: TileHeight + 2)
                    tileNode.position = pointFor(column: column, row: row)
                    maskLayer.addChild(tileNode)
                }
            }
        }
        
        for row in 0..<NumRows {
                        for column in 0..<NumColumns {
                            if level.tileAt(column: column, row: row) != nil {
                                let tileNode = SKSpriteNode(imageNamed: "whiteBox")
                                tileNode.size = CGSize(width: TileWidth + 2 , height: TileHeight + 2)
                                tileNode.alpha = 0.2
                                tileNode.position = pointFor(column: column, row: row)
                                tilesLayer.addChild(tileNode)
                            }
                        }
                    }
        
        // The tile pattern is drawn *in between* the level tiles. That's why
        // there is an extra column and row of them.
//        for row in 0...NumRows {
//            for column in 0...NumColumns {
//
//                let topLeft     = (column > 0) && (row < NumRows)
//                    && level.tileAt(column: column - 1, row: row) != nil
//                let bottomLeft  = (column > 0) && (row > 0)
//                    && level.tileAt(column: column - 1, row: row - 1) != nil
//                let topRight    = (column < NumColumns) && (row < NumRows)
//                    && level.tileAt(column: column, row: row) != nil
//                let bottomRight = (column < NumColumns) && (row > 0)
//                    && level.tileAt(column: column, row: row - 1) != nil
//
//                // The tiles are named from 0 to 15, according to the bitmask that is
//                // made by combining these four values
//
//                var value = topLeft.hashValue
//                value = value | topRight.hashValue << 1
//                value = value | bottomLeft.hashValue << 2
//                value = value | bottomRight.hashValue << 3
//
//                // Values 0 (no tiles), 6 and 9 (two opposite tiles) are not drawn.
//                if value != 0 && value != 6 && value != 9 {
//                    //let name = String(format: "Tile_%ld", value)
//                    let tileNode = SKSpriteNode(imageNamed: "whiteBox")
//                    tileNode.size = CGSize(width: TileWidth, height: TileHeight)
//                    tileNode.alpha = 0.3
//                    var point = pointFor(column: column, row: row)
//                    point.x -= TileWidth/2
//                    point.y -= TileHeight/2
//                    tileNode.position = point
//                    tilesLayer.addChild(tileNode)
//                }
//            }
//        }
    }
    
    func addSprites(for characters: Set<Character>) {
                for character in characters {
                    let sprite = SKSpriteNode(imageNamed: character.characterType.spriteName)
                    sprite.size = CGSize(width: TileWidth, height: TileHeight)
                    sprite.position = pointFor(column: character.column, row: character.row)
                    characterLayer.addChild(sprite)
                    character.sprite = sprite
                    
                    sprite.alpha = 0
                    sprite.xScale = 0.5
                    sprite.yScale = 0.5
                    
                    sprite.run(
                        SKAction.sequence([
                            SKAction.wait(forDuration: 0.25, withRange: 0.5),
                            SKAction.group([
                                SKAction.fadeIn(withDuration: 0.25),
                                SKAction.scale(to: 1.0, duration: 0.25)
                                ])
                            ]))
                }
            }
    

    
    func removeAllCharactereSprites() {
        characterLayer.removeAllChildren()
    }
    
    
    // MARK: Point conversion
    
    func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
      
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
            return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    
    // MARK: Character Swapping
    
  
    func trySwap(horizontal horzDelta: Int, vertical vertDelta: Int) {
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        
     
        guard toColumn >= 0 && toColumn < NumColumns else { return }
        guard toRow >= 0 && toRow < NumRows else { return }
        
        
        if let toCharacter = level.characterAt(column: toColumn, row: toRow),
            let fromCharacter = level.characterAt(column: swipeFromColumn!, row: swipeFromRow!),
            let handler = swipeHandler {
            // Communicate this swap request back to the ViewController.
            let swap = Swap(characterA: fromCharacter, characterB: toCharacter)
            handler(swap)
        }
    }
    
    func showSelectionIndicator(for character: Character) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
    }
    
    func hideSelectionIndicator() {
        selectionSprite.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()]))
    }
    
    
    // MARK: Animations
    
    func animate(swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.characterA.sprite!
        let spriteB = swap.characterB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.3
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        spriteA.run(moveA, completion: completion)
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        spriteB.run(moveB)
        
        run(swapSound)
    }
    
    func animateInvalidSwap(_ swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.characterA.sprite!
        let spriteB = swap.characterB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: TimeInterval = 0.2
        
        let moveA = SKAction.move(to: spriteB.position, duration: duration)
        moveA.timingMode = .easeOut
        
        let moveB = SKAction.move(to: spriteA.position, duration: duration)
        moveB.timingMode = .easeOut
        
        spriteA.run(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.run(SKAction.sequence([moveB, moveA]))
        
        run(invalidSwapSound)
    }
    
    func animateMatchedCharacters(for chains: Set<Chain>, completion: @escaping () -> ()) {
        for chain in chains {
            animateScore(for: chain)
            
            for character in chain.characters {
                
           
                if let sprite = character.sprite {
                    if sprite.action(forKey: "removing") == nil {
                        let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                        scaleAction.timingMode = .easeOut
                        sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                                   withKey: "removing")
                    }
                }
            }
        }
        run(matchSound)
        run(SKAction.wait(forDuration: 0.3), completion: completion)
    }
    
    func animateFallingCharacterFor(columns: [[Character]], completion: @escaping () -> ()) {
        var longestDuration: TimeInterval = 0
        for array in columns {
            for (idx, character) in array.enumerated() {
                let newPosition = pointFor(column: character.column, row: character.row)
                
           
                let delay = 0.05 + 0.15*TimeInterval(idx)
                
                let sprite = character.sprite!
                
                
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
                longestDuration = max(longestDuration, duration + delay)
                
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.group([moveAction, fallingCharacterSound])]))
            }
        }
        
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    func animateNewCharacter(_ columns: [[Character]], completion: @escaping () -> ()) {
  
        var longestDuration: TimeInterval = 0
        
        for array in columns {
           
            let startRow = array[0].row + 1
            
            for (idx, character) in array.enumerated() {
                
                let sprite = SKSpriteNode(imageNamed: character.characterType.spriteName)
                sprite.size = CGSize(width: TileWidth, height: TileHeight)
                sprite.position = pointFor(column: character.column, row: startRow)
                characterLayer.addChild(sprite)
                character.sprite = sprite
                
                // fall after one another.
                let delay = 0.1 + 0.2 * TimeInterval(array.count - idx - 1)
                
                let duration = TimeInterval(startRow - character.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                
                // Animate the sprite falling down. Also fade it in to make the sprite
                // appear less abruptly.
                let newPosition = pointFor(column: character.column, row: character.row)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.alpha = 0
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.group([
                            SKAction.fadeIn(withDuration: 0.05),
                            moveAction,
                            addCharacterSound])
                        ]))
            }
        }
        
        // Wait until the animations are done before we continue.
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    func animateScore(for chain: Chain) {
     
        let firstSprite = chain.firstCharacter().sprite!
        let lastSprite = chain.lastCharacter().sprite!
        let centerPosition = CGPoint(
            x: (firstSprite.position.x + lastSprite.position.x)/2,
            y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
        
        // Add a label for the score that slowly floats up.
        let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        scoreLabel.fontSize = 16
        scoreLabel.text = String(format: "%ld", chain.score)
        scoreLabel.position = centerPosition
        scoreLabel.zPosition = 300
        characterLayer.addChild(scoreLabel)
        
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: 3), duration: 0.7)
        moveAction.timingMode = .easeOut
        scoreLabel.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
    
    func animateGameOver(_ completion: @escaping () -> ()) {
        let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .easeIn
        gameLayer.run(action, completion: completion)
    }
    
    func animateBeginGame(_ completion: @escaping () -> ()) {
        gameLayer.isHidden = false
        gameLayer.position = CGPoint(x: 0, y: size.height)
        let action = SKAction.move(by: CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .easeOut
        gameLayer.run(action, completion: completion)
    }
    
    
    // MARK: Swipe Handlers
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: characterLayer)
        
        // If the touch is inside a square, then this might be the start of a
        // swipe motion.
        let (success, column, row) = convertPoint(location)
        if success {
            if let character = level.characterAt(column: column, row: row) {
                // Remember in which column and row the swipe started, so we can compare
                // them later to find the direction of the swipe. This is also the first
                swipeFromColumn = column
                swipeFromRow = row
                showSelectionIndicator(for: character)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If swipeFromColumn is nil then either the swipe began outside
        // to ignore the rest of the motion.
        guard swipeFromColumn != nil else { return }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: characterLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            // Figure out in which direction the player swiped. Diagonal swipes
            // are not allowed.
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn! {          // swipe left
                horzDelta = -1
            } else if column > swipeFromColumn! {   // swipe right
                horzDelta = 1
            } else if row < swipeFromRow! {         // swipe down
                vertDelta = -1
            } else if row > swipeFromRow! {         // swipe up
                vertDelta = 1
            }
            
            // Only try swapping when the user swiped into a new square.
            if horzDelta != 0 || vertDelta != 0 {
                trySwap(horizontal: horzDelta, vertical: vertDelta)
                hideSelectionIndicator()
                
                // Ignore the rest of this swipe motion from now on.
                swipeFromColumn = nil
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Remove the selection indicator with a fade-out. We only need to do this
        // when the player didn't actually swipe.
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            hideSelectionIndicator()
        }
        
        // If the gesture ended, regardless of whether if was a valid swipe or not,
        // reset the starting column and row numbers.
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
}


