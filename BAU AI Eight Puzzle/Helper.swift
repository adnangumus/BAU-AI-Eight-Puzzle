//
//  Helper.swift
//  BAU AI Eight Puzzle
//
//  Created by cambaz on 22/10/15.
//  Copyright © 2015 Adnan Gümüş. All rights reserved.
//

import Foundation

open class Helper{
    let events = EventManager()
    
    class var sharedInstance :Helper {
        struct Singleton {
            static let instance = Helper()
        }
        return Singleton.instance
    }
}

struct MoveCommand {
    //let direction : MoveDirection
    let from: (Int, Int)
    let to: (Int, Int)
    let completion : (Bool) -> ()
}
