//
//  ChooseGameScene.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 8/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class ChooseGameScene: CCNode
{
    var gameData: GameData!
    
    func playFlappy()
    {
        MiscMethods.toGameplayScene(gameData, nameOfGame: "Flappy")
    }
    
    func playShoot()
    {
        MiscMethods.toGameplayScene(gameData, nameOfGame: "Shoot")
    }
}
