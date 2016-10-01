//
//  GameModel.swift
//  BAU AI Eight Puzzle
//
//  Created by cambaz on 21/10/15.
//  Copyright © 2015 Adnan Gümüş. All rights reserved.
//

import Foundation


class GameModel : NSObject {
    let dimension : Int
    let threshold : Int
    
    var queue: [MoveCommand]
    var timer: Timer
    
    let maxCommands = 1000
    let queueDelay = 0.6
    
    override init() {
        dimension = 0
        threshold = 0
        queue = [MoveCommand]()
        timer = Timer()
        super.init()
    }
    
    /// Reset the game state.
    func reset() {
        queue.removeAll(keepingCapacity: true)
        timer.invalidate()
    }
    
    func queueMove(_ from: (Int, Int), to: (Int, Int), completion: @escaping (Bool) -> ()) {
        guard queue.count <= maxCommands else {
            // Queue is wedged. This should actually never happen in practice.
            return
        }
        
        queue.append(MoveCommand(from: from, to: to, completion: completion))
        if !timer.isValid {
            // Timer isn't running, so fire the event immediately
            timerFired(timer)
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------//
    
    /// Inform the game model that the move delay timer fired. Once the timer fires, the game model tries to execute a
    /// single move that changes the game state.
    func timerFired(_: Timer) {
        if queue.count == 0 {
            return
        }
        // Go through the queue until a valid command is run or the queue is empty
        var changed = false
        while queue.count > 0 {
            let command = queue[0]
            queue.remove(at: 0)
            changed = true//performMove(command.from,to: command.to)
            command.completion(changed)
            if changed {
                // If the command doesn't change anything, we immediately run the next one
                break
            }
        }
        if changed {
            timer = Timer.scheduledTimer(timeInterval: queueDelay,
                target: self,
                selector:
                #selector(GameModel.timerFired(_:)),
                userInfo: nil,
                repeats: false)
        }
    }
}
