//
//  Number.swift
//  BAU AI Eight Puzzle
//
//  Created by cambaz on 21/10/15.
//  Copyright © 2015 Adnan Gümüş. All rights reserved.
//

import SpriteKit

class Number: CustomStringConvertible, Hashable {
    var column: Int
    var row: Int
    let numberType: NumberType
    var sprite: SKSpriteNode?
    var value:Int?
    
    init(column: Int, row: Int, numberType: NumberType, v: Int) {
        self.column = column
        self.row = row
        self.numberType = numberType
        self.value = v
    }
    
    var description: String {
        return "type:\(numberType) square:(\(column),\(row))"
    }
    
    var hashValue: Int {
        return row*10 + column
    }
}

enum NumberType: Int, CustomStringConvertible {
    case unknown = 0,empty, one, two, three, four, five, six, seven, eight
    
    var spriteName: String {
        let spriteNames = [
            "empty",
            "one",
            "two",
            "three",
            "four",
            "five",
            "six",
            "seven",
            "eight"]
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    static func random() -> NumberType {
        return NumberType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
    
    static func get(_ i : Int) -> NumberType {
        return NumberType(rawValue: i)!
    }
    
    var description: String {
        return spriteName
    }
}

func ==(lhs: Number, rhs: Number) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
