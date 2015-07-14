//
//  GameplaySling.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class GameplaySling: CCNode
{
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var slingPocket: CCSprite!
    var quizWords = Dictionary<String, String>()
    
    override func onEnterTransitionDidFinish()
    {
//        let actionFollow = CCActionFollow(target: slingPocket, worldBoundary: boundingBox())
//        gamePhysicsNode.runAction(actionFollow)
        gamePhysicsNode.debugDraw = true
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        //let touchLocation = touch.locationInNode(contentNode)
        
    }
    
    func initializeQuizWordsArray()
    {
        quizWords["Vriska"] = "There are so many irons in the fire that the fire has retired"
        quizWords["Robin"] = "Oh they've probably been shot to pieces and maimed"
        quizWords["Keladry"] = "Be like stone. Pretty and smooth, but able to bash someone's head in"
        quizWords["Tetra"] = "Being a pirate is tough, especially when people don't want you to steal their things"
        quizWords["Inkling"] = "Identity crisis"
    }
   
    
}
