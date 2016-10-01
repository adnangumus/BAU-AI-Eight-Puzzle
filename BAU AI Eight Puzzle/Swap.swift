//
//  Swap.swift
//  BAU AI Eight Puzzle
//
//  Created by cambaz on 21/10/15.
//  Copyright © 2015 Adnan Gümüş. All rights reserved.
//

struct Swap: CustomStringConvertible, Hashable {
    let numberA: Number
    let numberB: Number
    
    init(cookieA: Number, cookieB: Number) {
        self.numberA = cookieA
        self.numberB = cookieB
    }
    
    var description: String {
        return "swap \(numberA) with \(numberB)"
    }
    
    var hashValue: Int {
        return numberA.hashValue ^ numberB.hashValue
    }
}

func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.numberA == rhs.numberA && lhs.numberB == rhs.numberB) ||
        (lhs.numberB == rhs.numberA && lhs.numberA == rhs.numberB)
}
