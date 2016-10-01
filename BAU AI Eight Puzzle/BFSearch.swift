//
//  BFSearch.swift
//  BAU AI Eight Puzzle
//
//  Created by cambaz on 21/10/15.
//  Copyright © 2015 Adnan Gümüş. All rights reserved.
//

import Foundation

open class BFSearch
{
    var isProcessing:Bool!{
        didSet{
            Helper.sharedInstance.events.trigger(eventName: "isProcessing", information: isProcessing)
        }
    }
    
    var isStopped:Bool!
    
    class var sharedInstance :BFSearch {
        struct Singleton {
            static let instance = BFSearch()
        }
        return Singleton.instance
    }
    
    func search (_ board:[Int], goal:[Int]){
        let root = SearchNode(s: PuzzleState(board: board, goal: goal))
        let q = Queue<SearchNode>()
        q.enqueue(root)
        performSearch(q)
    }
    
    func performSearch(_ q:Queue<SearchNode>){
        var searchCount = 1
        self.isProcessing = true
        self.isStopped = false
        while (!q.isEmpty() && !isStopped){
            var tempNode = q.dequeue()
            if (!tempNode!.getCurState().isGoal()){
                var tempSuccessors = tempNode!.getCurState().genSuccessors
                for i in (0 ..< tempSuccessors.count) {
                    let newNode = SearchNode(prev: tempNode!, s: tempSuccessors[i], c: (tempNode!.getCost() + tempSuccessors[i].findCost()), h: 0, d:searchCount)
                    if !checkRepeats(newNode){
                        q.enqueue(newNode)
                    }
                }
                Helper.sharedInstance.events.trigger(eventName: "nodes", information: String(searchCount))
                searchCount += 1
            }
            else{
                let solutionPath = Stack<SearchNode>()
                solutionPath.push(tempNode!)
                tempNode = tempNode!.getParent()
                
                if tempNode == nil{
                    Helper.sharedInstance.events.trigger(eventName: "alert", information: "Problem and Goal are same")
                    self.isProcessing = false
                    return
                }
                
                while ((tempNode!.getParent()) != nil){
                    solutionPath.push(tempNode!)
                    tempNode = tempNode!.getParent()
                }
                
                solutionPath.push(tempNode!)
                
                let loopSize = solutionPath.count
                
                for _ in (0 ..< loopSize){
                    tempNode = solutionPath.pop()
                    tempNode!.getCurState().printState()
                }
                
                Helper.sharedInstance.events.trigger(eventName: "depth", information: String("-"))
                Helper.sharedInstance.events.trigger(eventName: "cost", information: String(tempNode!.getCost())) //"The cost was:"
                Helper.sharedInstance.events.trigger(eventName: "nodes", information: String(searchCount)) //"The number of nodes examined: "
                self.isProcessing = false
                return
            }
        }
        
        Helper.sharedInstance.events.trigger(eventName: "nodes", information: String(searchCount)) //The number of nodes examined:
        self.isProcessing = false
    }
    
    func stopSearch(){
        isStopped = true
    }
    
    func checkRepeats(_ n:SearchNode) -> Bool{
        var n = n
        var retValue = false
        let checkNode = n
        
        while (n.getParent() != nil && !retValue){
            if n.getParent().getCurState().equals(checkNode.getCurState()){
                retValue = true
            }
            n = n.getParent()
        }
        return retValue
    }
}