//
//  GameScene.swift
//  BAU AI Eight Puzzle
//
//  Created by cambaz on 21/10/15.
//  Copyright (c) 2015 Adnan Gümüş. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    // This is marked as ! because it will not initially have a value, but pretty
    // soon after the GameScene is created it will be given a Level object, and
    // from then on it will always have one (it will never be nil again).
    var level: Level!
    var levelGoal: Level!
    var model: GameModel?
    // The scene handles touches. If it recognizes that the user makes a swipe,
    // it will call this swipe handler. This is how it communicates back to the
    // ViewController that a swap needs to take place. You could also use a
    // delegate for this.
    var swipeHandler: ((Swap) -> ())?
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let numbersLayer = SKNode()
    let numbersLayerGoal = SKNode()
    let tilesLayer = SKNode()
    let tilesLayerGoal = SKNode()
    
    let labelGoal = SKLabelNode()
    let labelInitial = SKLabelNode()
    
    // The column and row numbers of the cookie that the player first touched
    // when he started his swipe movement. These are marked ? because they may
    // become nil (meaning no swipe is in progress).
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    
    // Sprite that is drawn on top of the cookie that the player is trying to swap.
    var selectionSprite = SKSpriteNode()
    
    // Pre-load the resources
    let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
    let fallingNumberSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
    let addNumberSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
    
    // MARK: Game Setup
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        model = GameModel()

        // Put an image on the background. Because the scene's anchorPoint is
        // (0.5, 0.5), the background image will always be centered on the screen.
        let background = SKSpriteNode(imageNamed: "Background")
        addChild(background)
        
        // Add a new node that is the container for all other layers on the playing
        // field. This gameLayer is also centered in the screen.
        addChild(gameLayer)

        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        let layerPositionGoal = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -layerPosition.y - TileHeight * CGFloat(NumRows) / 1.7)


        labelGoal.text = "Goal State"
        labelGoal.fontSize = 18
        labelGoal.fontName = "DIN Condensed"
        labelGoal.fontColor = UIColor.white
        labelGoal.position = CGPoint(x: self.frame.midX, y: (self.frame.midY + TileHeight*5.4))
        
        labelInitial.text = "Initial State"
        labelInitial.fontSize = 18
        labelInitial.fontName = "DIN Condensed"
        labelInitial.fontColor = UIColor.white
        labelInitial.position = CGPoint(x: self.frame.midX, y: (self.frame.midY + TileHeight*1.6))
        
        let tileNodeInitial = SKSpriteNode(imageNamed: "Tile")
        tileNodeInitial.position = labelInitial.position
        tileNodeInitial.size = CGSize(width: TileWidth*3, height: TileHeight)
        gameLayer.addChild(tileNodeInitial)
        
        let tileNodeGoal = SKSpriteNode(imageNamed: "Tile")
        tileNodeGoal.position = labelGoal.position
        tileNodeGoal.size = CGSize(width: TileWidth*3, height: TileHeight)
        gameLayer.addChild(tileNodeGoal)
        
        
        // The tiles layer represents the shape of the level. It contains a sprite
        // node for each square that is filled in.
        tilesLayerGoal.position = layerPositionGoal
        gameLayer.addChild(tilesLayerGoal)
        
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        
        gameLayer.addChild(labelGoal)
        gameLayer.addChild(labelInitial)
        
        // This layer holds the Cookie sprites. The positions of these sprites
        // are relative to the cookiesLayer's bottom-left corner.
        numbersLayerGoal.position = layerPositionGoal
        gameLayer.addChild(numbersLayerGoal)
        
        numbersLayer.position = layerPosition
        gameLayer.addChild(numbersLayer)
   
        // nil means that these properties have invalid values.
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    func removeAllNumbers() {
        numbersLayer.removeAllChildren()
    }
    
    func removeAllNumbersGoal() {
        numbersLayerGoal.removeAllChildren()
    }
    
    func addNumbers(_ numbers: Set<Number>) {
        for number in numbers {
            // Create a new sprite for the cookie and add it to the cookiesLayer.
            let sprite = SKSpriteNode(imageNamed: number.numberType.spriteName)
            sprite.position = pointForColumn(number.column, row:number.row)
            numbersLayer.addChild(sprite)
            number.sprite = sprite
            
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
    
    func addNumbersGoal(_ numbers: Set<Number>) {
        for number in numbers {
            // Create a new sprite for the cookie and add it to the cookiesLayer.
            let sprite = SKSpriteNode(imageNamed: number.numberType.spriteName)
            sprite.position = pointForColumn(number.column, row:number.row)
            numbersLayerGoal.addChild(sprite)
            number.sprite = sprite
            
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
    
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                // If there is a tile at this position, then create a new tile
                // sprite and add it to the mask layer.
                if let _ = level.tileAtColumn(column, row: row) {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = pointForColumn(column, row: row)
                    //print(tileNode.position)
                    //print (String(column) + "-" + String(row))
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    func addTilesGoal() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                // If there is a tile at this position, then create a new tile
                // sprite and add it to the mask layer.
                if let _ = levelGoal.tileAtColumn(column, row: row) {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = pointForColumn(column, row: row)
                    tilesLayerGoal.addChild(tileNode)
                }
            }
        }
    }
    
    // MARK: Conversion Routines
    
    // Converts a column,row pair into a CGPoint that is relative to the cookieLayer.
    func pointForColumn(_ column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    // Converts a point relative to the cookieLayer into column and row numbers.
    func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        // Is this a valid location within the cookies layer? If yes,
        // calculate the corresponding row and column numbers.
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    func swipe(_ fromColumn:Int, fromRow:Int, toColumn:Int, toRow:Int){
        model?.queueMove((fromRow, fromColumn), to: (toRow, toColumn), completion: { (changed: Bool) -> () in
            if let cookie = self.level.numberAtColumn(fromColumn, row: fromRow) {
                self.swipeFromColumn = fromColumn
                self.swipeFromRow = fromRow
                self.showSelectionIndicatorForCookie(cookie)
                
                
                self.trySwapHorizontal(toColumn, toRow: toRow)
                self.hideSelectionIndicator()
                
                // Ignore the rest of this swipe motion from now on.
                self.swipeFromColumn = nil
            }
        })
    }
    
    
    // MARK: Detecting Swipes
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Convert the touch location to a point relative to the cookiesLayer.
        let touch = touches.first as UITouch?
        let location = touch!.location(in: numbersLayer)
        
        // If the touch is inside a square, then this might be the start of a
        // swipe motion.
        let (success, column, row) = convertPoint(location)
        if success {
            // The touch must be on a cookie, not on an empty tile.
            if let cookie = level.numberAtColumn(column, row: row) {
                // Remember in which column and row the swipe started, so we can compare
                // them later to find the direction of the swipe. This is also the first
                // cookie that will be swapped.
                swipeFromColumn = column
                swipeFromRow = row
                
                showSelectionIndicatorForCookie(cookie)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If swipeFromColumn is nil then either the swipe began outside
        // the valid area or the game has already swapped the cookies and we need
        // to ignore the rest of the motion.
        if swipeFromColumn == nil { return }
        
        let touch = touches.first as UITouch?
        let location = touch!.location(in: numbersLayer)
        
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
                trySwapHorizontal(horzDelta, vertical: vertDelta)
                hideSelectionIndicator()
                
                // Ignore the rest of this swipe motion from now on.
                swipeFromColumn = nil
            }
        }
    }
    
    func trySwapHorizontal(_ toColumn: Int,  toRow: Int) {
        // Going outside the bounds of the array? This happens when the user swipes
        // over the edge of the grid. We should ignore such swipes.
        if toColumn < 0 || toColumn >= NumColumns { return }
        if toRow < 0 || toRow >= NumRows { return }
        
        // Can't swap if there is no cookie to swap with. This happens when the user
        // swipes into a gap where there is no tile.
        if let toCookie = level.numberAtColumn(toColumn, row: toRow),
            let fromCookie = level.numberAtColumn(swipeFromColumn!, row: swipeFromRow!),
            let handler = swipeHandler {
                
                // Communicate this swap request back to the ViewController.
                let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
                handler(swap)
        }
    }
    
    
    
    
    // We get here after the user performs a swipe. This sets in motion a whole
    // chain of events: 1) swap the cookies, 2) remove the matching lines, 3)
    // drop new cookies into the screen, 4) check if they create new matches,
    // and so on.
    func trySwapHorizontal(_ horzDelta: Int, vertical vertDelta: Int) {
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        
        // Going outside the bounds of the array? This happens when the user swipes
        // over the edge of the grid. We should ignore such swipes.
        if toColumn < 0 || toColumn >= NumColumns { return }
        if toRow < 0 || toRow >= NumRows { return }
        
        // Can't swap if there is no cookie to swap with. This happens when the user
        // swipes into a gap where there is no tile.
        if let toCookie = level.numberAtColumn(toColumn, row: toRow),
            let fromCookie = level.numberAtColumn(swipeFromColumn!, row: swipeFromRow!),
            let handler = swipeHandler {
                
                // Communicate this swap request back to the ViewController.
                let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
                handler(swap)
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
    
    // MARK: Animations
    
    func animateSwap(_ swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.numberA.sprite!
        let spriteB = swap.numberB.sprite!
        
        // Put the cookie you started with on top.
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: TimeInterval = 0.3
        
        let moveA = SKAction.move(to: spriteB.position, duration: Duration)
        moveA.timingMode = .easeOut
        spriteA.run(moveA, completion: completion)
        
        let moveB = SKAction.move(to: spriteA.position, duration: Duration)
        moveB.timingMode = .easeOut
        spriteB.run(moveB)
        
        run(swapSound)
    }
    
    func animateInvalidSwap(_ swap: Swap, completion: @escaping () -> ()) {
        let spriteA = swap.numberA.sprite!
        let spriteB = swap.numberB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: TimeInterval = 0.2
        
        let moveA = SKAction.move(to: spriteB.position, duration: Duration)
        moveA.timingMode = .easeOut
        
        let moveB = SKAction.move(to: spriteA.position, duration: Duration)
        moveB.timingMode = .easeOut
        
        spriteA.run(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.run(SKAction.sequence([moveB, moveA]))
        
        run(invalidSwapSound)
    }
    
    // MARK: Selection Indicator
    
    func showSelectionIndicatorForCookie(_ number: Number) {
        // If the selection indicator is still visible, then first remove it.
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        // Add the selection indicator as a child to the cookie that the player
        // tapped on and fade it in. Note: simply setting the texture on the sprite
        // doesn't give it the correct size; using an SKAction does.
        if let sprite = number.sprite {
            let texture = SKTexture(imageNamed: number.numberType.highlightedSpriteName)
            selectionSprite.size = texture.size()
            selectionSprite.run(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }
    
    func hideSelectionIndicator() {
        selectionSprite.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()]))
    }
}
