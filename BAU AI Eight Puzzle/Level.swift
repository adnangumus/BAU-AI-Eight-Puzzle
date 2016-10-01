//
//  Level.swift
//  BAU AI Eight Puzzle
//
//  Created by cambaz on 21/10/15.
//  Copyright © 2015 Adnan Gümüş. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level {
    // The 2D array that keeps track of where the Cookies are.
    fileprivate var numbers = Array2D<Number>(columns: NumColumns, rows: NumRows)
    
    // The 2D array that contains the layout of the level.
    fileprivate var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
    // The list of swipes that result in a valid swap. Used to determine whether
    // the player can make a certain swap, whether the board needs to be shuffled,
    // and to generate hints.
    fileprivate var possibleSwaps = Set<Swap>()
    
    // Create a level by loading it from a file.
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            
            // The dictionary contains an array named "tiles". This array contains
            // one element for each row of the level. Each of those row elements in
            // turn is also an array describing the columns in that row. If a column
            // is 1, it means there is a tile at that location, 0 means there is not.
            if let tilesArray: AnyObject = dictionary["tiles"] {
                
                // Loop through the rows...
                for (row, rowArray) in (tilesArray as! [[Int]]).enumerated() {
                    
                    // Note: In Sprite Kit (0,0) is at the bottom of the screen,
                    // so we need to read this file upside down.
                    let tileRow = NumRows - row - 1
                    
                    // Loop through the columns in the current row...
                    for (column, value) in rowArray.enumerated() {
                        
                        // If the value is 1, create a tile object.
                        if value == 1 {
                            tiles[column, tileRow] = Tile()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Game Setup
    
    // Fills up the level with new Cookie objects. The level is guaranteed free
    // from matches at this point.
    // You call this method at the beginning of a new game and whenever the player
    // taps the Shuffle button.
    // Returns a set containing all the new Cookie objects.
    func shuffle() -> Set<Number> {
        var set: Set<Number>
        
        // Removes the old cookies and fills up the level with all new ones.
        set = createInitialCookies()
        
        return set
    }
    
    fileprivate func gameboardEmptySpots() -> [(Int, Int)] {
        var buffer : [(Int, Int)] = []
        for i in 0..<NumRows{
            for j in 0..<NumColumns {
                if  numbers[j, i ] == nil && self.tiles[j,i] != nil {
                    buffer += [(j, i)]
                }
                else{
                    
                }
            }
        }
        return buffer
    }
    
    fileprivate func createInitialCookies() -> Set<Number> {
        var set = Set<Number>()
        for i in (0 ..< NumColumns){
            let openSpots = gameboardEmptySpots()
            if openSpots.count <= 0 {
                // No more open spots; don't even bother
                return set
            }
            // Randomly select an open spot, and put a new tile there
            let idx = Int(arc4random_uniform(UInt32(openSpots.count-1)))
            let (x, y) = openSpots[idx]
            
            if self.tiles[x,y] != nil{
                let numberType: NumberType =  NumberType.get(i+1)
                let number = Number(column: x, row: y, numberType: numberType, v:i)
                numbers[x, y] = number
                
                // Also add the cookie to the set so we can tell our caller about it.
                set.insert(number)
            }
        }
        
        
        
        // Loop through the rows and columns of the 2D array. Note that column 0,
        // row 0 is in the bottom-left corner of the array.
        //    for row in 0..<NumRows {
        //      for column in 0..<NumColumns {
        //
        //        // Only make a new cookie if there is a tile at this spot.
        //        if tiles[column, row] != nil {
        //
        //          // Pick the cookie type at random, and make sure that this never
        //          // creates a chain of 3 or more. We want there to be 0 matches in
        //          // the initial state.
        //          var cookieType: CookieType
        //          repeat {
        //            cookieType = CookieType.random()
        //          }
        //          while (column >= 2 &&
        //                  cookies[column - 1, row]?.cookieType == cookieType &&
        //                  cookies[column - 2, row]?.cookieType == cookieType)
        //             || (row >= 2 &&
        //                  cookies[column, row - 1]?.cookieType == cookieType &&
        //                  cookies[column, row - 2]?.cookieType == cookieType)
        //
        //          // Create a new cookie and add it to the 2D array.
        //          let cookie = Cookie(column: column, row: row, cookieType: cookieType)
        //          cookies[column, row] = cookie
        //
        //          // Also add the cookie to the set so we can tell our caller about it.
        //          set.insert(cookie)
        //        }
        //      }
        //    }
        return set
    }
    
    // MARK: Querying the Level
    
    // Returns the cookie at the specified column and row, or nil when there is none.
    func numberAtColumn(_ column: Int, row: Int) -> Number? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return numbers[column, row]
    }
    
    // Determines whether there's a tile at the specified column and row.
    func tileAtColumn(_ column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    // Determines whether the suggested swap is a valid one, i.e. it results in at
    // least one new chain of 3 or more cookies of the same type.
    func isPossibleSwap(_ swap: Swap) -> Bool {
        return swap.numberB.value == 0 ? true : false
    }
    
    // MARK: Swapping
    
    // Swaps the positions of the two cookies from the Swap object.
    func performSwap(_ swap: Swap) {
        // Need to make temporary copies of these because they get overwritten.
        let columnA = swap.numberA.column
        let rowA = swap.numberA.row
        let columnB = swap.numberB.column
        let rowB = swap.numberB.row
        
        // Swap the cookies. We need to update the array as well as the column
        // and row properties of the Cookie objects, or they go out of sync!
        numbers[columnA, rowA] = swap.numberB
        swap.numberB.column = columnA
        swap.numberB.row = rowA
        
        numbers[columnB, rowB] = swap.numberA
        swap.numberA.column = columnB
        swap.numberA.row = rowB
    }
    
    // MARK: Detecting Swaps
    
    // Recalculates which moves are valid.
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let number = numbers[column, row] {
                    
                    // Is it possible to swap this cookie with the one on the right?
                    // Note: don't need to check the last column.
                    if column < NumColumns - 1 {
                        
                        // Have a cookie in this spot? If there is no tile, there is no cookie.
                        if let other = numbers[column + 1, row] {
                            // Swap them
                            numbers[column, row] = other
                            numbers[column + 1, row] = number
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column + 1, row: row) ||
                                hasChainAtColumn(column, row: row) {
                                    set.insert(Swap(cookieA: number, cookieB: other))
                            }
                            
                            // Swap them back
                            numbers[column, row] = number
                            numbers[column + 1, row] = other
                        }
                    }
                    
                    // Is it possible to swap this cookie with the one above?
                    // Note: don't need to check the last row.
                    if row < NumRows - 1 {
                        
                        // Have a cookie in this spot? If there is no tile, there is no cookie.
                        if let other = numbers[column, row + 1] {
                            // Swap them
                            numbers[column, row] = other
                            numbers[column, row + 1] = number
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column, row: row + 1) ||
                                hasChainAtColumn(column, row: row) {
                                    set.insert(Swap(cookieA: number, cookieB: other))
                            }
                            
                            // Swap them back
                            numbers[column, row] = number
                            numbers[column, row + 1] = other
                        }
                    }
                }
            }
        }
        
        possibleSwaps = set
    }
    
    fileprivate func hasChainAtColumn(_ column: Int, row: Int) -> Bool {
        // Here we do ! because we know there is a cookie here
        let numberType = numbers[column, row]!.numberType
        
        // Here we do ? because there may be no cookie there; if there isn't then
        // the loop will terminate because it is != cookieType. (So there is no
        // need to check whether cookies[i, row] != nil.)
        var horzLength = 1
//        for var i = column - 1; i >= 0 && numbers[i, row]?.numberType == numberType; i-=1, horzLength+=1 {
//        
//        }
        
        for i in stride(from: column - 1, to: 0, by: -1){
            if i >= 0 && numbers[i, row]?.numberType == numberType{
                horzLength+=1
            }
            else{
                break
            }
        }
        
        //for var i = column + 1; i < NumColumns && numbers[i, row]?.numberType == numberType; i=i+1, horzLength=horzLength+1 { }
        
        for i in stride(from: column + 1, to: NumColumns-1, by: 1){
            if i < NumColumns && numbers[i, row]?.numberType == numberType{
                horzLength+=1
            }
            else{
                break
            }
        }
        
        if horzLength >= 3 { return true }
        
        var vertLength = 1
        //for var i = row - 1; i >= 0 && numbers[column, i]?.numberType == numberType; --i, ++vertLength { }
        
        
        for i in stride(from: row - 1, to: 0, by: -1){
            if i >= 0 && numbers[column, i]?.numberType == numberType{
                vertLength+=1
            }
            else{
                break
            }
        }
        
        //for var i = row + 1; i < NumRows && numbers[column, i]?.numberType == numberType; ++i, ++vertLength { }
        
        for i in stride(from: row + 1, to: NumRows-1, by: 1){
            if i < NumRows && numbers[column, i]?.numberType == numberType{
                vertLength+=1
            }
            else{
                break
            }
        }
        
        return vertLength >= 3
    }
}

