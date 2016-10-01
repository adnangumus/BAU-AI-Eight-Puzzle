//
//  State.swift
//  BAU AI Eight Puzzle
//
//  Created by cambaz on 22/10/15.
//  Copyright © 2015 Adnan Gümüş. All rights reserved.
//

import Foundation


protocol State: class {
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
