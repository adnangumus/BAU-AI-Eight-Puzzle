//
//  SearchManager.swift
//  BAU AI Eight Puzzle
//
//  Created by cambaz on 27/10/15.
//  Copyright © 2015 Adnan Gümüş. All rights reserved.
//

import Foundation


open class SearchManager
{
    var isProcessing:Bool!{
        didSet{
            Helper.sharedInstance.events.trigger(eventName: "isProcessing", information: isProcessing)
        }
    }
    
    var isStopped:Bool!
    
    class var sharedInstance :SearchManager {
        struct Singleton {
            static let instance = SearchManager()
        }
        return Singleton.instance
    }
}


protocol Algo: class {
    // determine if current state is goal
    func isGoal() -> Bool
    // determine cost from initial state to THIS state
    func findCost() -> Double
    //print the current state
    func printState()
    //print cost
    func printCost()
    //print examined Nodes
    func printExaminedNodes()
    // generate successors to the current state
    var genSuccessors: [State] {get}
    // compare the actual state data
    func equals(_ s:State) -> Bool
}
