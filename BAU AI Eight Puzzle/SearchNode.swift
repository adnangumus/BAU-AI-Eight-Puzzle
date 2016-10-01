//
//  SearchNode.swift
//  BAU AI Eight Puzzle
//
//  Created by cambaz on 22/10/15.
//  Copyright © 2015 Adnan Gümüş. All rights reserved.
//

import Foundation


open class SearchNode
{
    var curState : State!
    var parent : SearchNode!
    var cost : Double = 0.0 // cost to get to this state
    var hCost : Double = 0.0 // heuristic cost
    var fCost : Double = 0.0 // f(n) cost
    var depth : Int = 0
    
    init() {
    }
    
    init(s: State) {
        curState = s
    }
    
    init(prev: SearchNode, s:State, c:Double, h:Double, d:Int) {
        parent = prev
        curState = s
        cost = c
        hCost = h
        fCost = cost + hCost
        depth = d
    }
    
    func getCurState() -> State{
        
        return curState
    }
    
    func getParent() -> SearchNode!{
        return parent
    }
    
    func getDepth() -> Int{
        return depth
    }
    
    func getCost() -> Double{
        return cost
    }
    
    func getHCost() -> Double{
        return hCost
    }
    
    func getFCost() -> Double{
        return fCost
    }
}
