//
//  Game.swift
//  microphone
//
//  Created by Jonah Alle Monne on 01/07/2018.
//  Copyright © 2018 Jonah Alle Monne. All rights reserved.
//

import Foundation

class Game {
    
    enum Status {
        case ongoing, over, ready
    }
    
    var currentProgress = 0
    var status :Status
    
    init() {
        status = .ready;
    }
    
    func startGame() -> Void {
        status = .ongoing
    }
    
    func endGame() -> Void {
        status = .over
    }
    
    func goForward() -> Void {
        if(status == .ongoing && currentProgress < 100){
            currentProgress += 10
        }else{
            endGame()
        }
    }
    
    func resetGame() -> Void {
        status = .ready
        currentProgress = 0
    }
    
}
