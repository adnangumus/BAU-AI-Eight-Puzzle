//
//  PuzzleState.swift
//  BAU AI Eight Puzzle
//
//  Created by cambaz on 22/10/15.
//  Copyright © 2015 Adnan Gümüş. All rights reserved.
//

import Foundation

open class PuzzleState : State
{
    var genSuccessors: [State] { get {
        var successors = [State]()
        let hole = getHole()
        
        if (hole != 0 && hole != 3 && hole != 6)
        {
            swapAndStore(hole - 1, d2: hole, s: &successors);
        }
        
        if (hole != 6 && hole != 7 && hole != 8)
        {
            swapAndStore(hole + 3, d2: hole, s: &successors);
        }
        
        if (hole != 0 && hole != 1 && hole != 2)
        {
            swapAndStore(hole - 3, d2: hole, s: &successors);
        }
        
        if (hole != 2 && hole != 5 && hole != 8)
        {
            swapAndStore(hole + 1,d2: hole, s: &successors);
        }
        
        return successors;
        
        }}
    var PUZZLE_SIZE = 9
    var outOfPlace = 0
    var manDist = 0
    
    var GOAL: [Int] //[1, 2, 3, 4, 5, 6, 7, 8, 0]
    var curBoard: [Int]
    
    var source:Int!
    var destination:Int!
    
    init(board:[Int], goal:[Int]){
        GOAL = goal
        curBoard = board
        setOutOfPlace()
        setManDist()
    }
    
    func setManDist(){
        
        var index = -1

        for y in (0 ..< 3)
        {
            for x in (0 ..< 3)
            {
                index += 1
                
                let val = (curBoard[index] - 1)
                
                if (val != -1)
                {
                    let horiz = val % 3
                    let vert = val / 3
                    
                    manDist += abs(vert - y) + abs(horiz - x)
                }
            }
        }
        
        //print("manDist: " + String(manDist))
    }
    
    func setOutOfPlace()
    {
        for i in (0 ..< curBoard.count)
        {
            if (curBoard[i] != GOAL[i])
            {
                self.outOfPlace += 1;
            }
        }
        //print("outOfPlace: " + String(outOfPlace))
    }
    
    func getHole() -> Int
    {
        var holeIndex : Int = -1
        
        for i in (0 ..< PUZZLE_SIZE)
        {
            if curBoard[i] == 0{
                holeIndex = i
            }
            
        }
        return holeIndex;
    }
    
    func getOutOfPlace() -> Int
    {
        return outOfPlace
    }
    
    func getManDist() -> Int
    {
        return manDist
    }
    
    func copyBoard(_ state : [Int]) -> [Int]
    {
        var ret:[Int] = []
        for i in (0 ..< PUZZLE_SIZE)
        {
            ret.append(state[i])
        }
        return ret
    }
    
    func swapAndStore(_ d1:Int, d2:Int, s: inout [State])
    {
        var cpy = copyBoard(curBoard)
        let temp = cpy[d1]
        cpy[d1] = curBoard[d2]
        cpy[d2] = temp
        let state = PuzzleState(board: cpy, goal: GOAL)
        state.source = d1
        state.destination = d2
        s.append(state)
    }
    
    func getCurBoard() -> [Int]
    {
        return curBoard
    }
    
    func isGoal() -> Bool {
        if curBoard == GOAL
        {
            return true
        }
        return false
    }
    
    func findCost() -> Double {
        return 1.0
    }
    
    func printState() {
        if source == nil{
            return
        }
        let array:[Int] = [source,destination]
        Helper.sharedInstance.events.trigger(eventName: "state", information: array)
    }
    
    func printCost() {
        Helper.sharedInstance.events.trigger(eventName: "cost", information: curBoard)
    }
    
    func printExaminedNodes(){
        Helper.sharedInstance.events.trigger(eventName: "nodes", information: curBoard)
    }
    
    func equals(_ s: State) -> Bool {
        if curBoard == (s as! PuzzleState).getCurBoard(){
            return true
        }
        else{
            return false
        }
    }
    
}
