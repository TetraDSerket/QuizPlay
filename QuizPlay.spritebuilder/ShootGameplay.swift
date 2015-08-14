//
//  GameplayShoot.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 8/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import Mixpanel

class ShootGameplay: Gameplay
{
    enum GameState
    {
        case Playing, GameOver, Tutorial, Paused, TempPaused
    }
    
    weak var hero: CCSprite!
    var heroSpeed: Int = 30
    weak var obstaclesLayer: CCNode!
    weak var bulletsLayer: CCNode!
    weak var buttonNode: CCNode!
    
    var sinceTouch: CCTime = 0
    var scrollSpeed: CGFloat = 80
    
    var obstacles : [CCNode] = [] //array of obstacles
    let firstObstaclePosition : CGFloat = 100
    let distanceBetweenObstacles : CGFloat = 180
    
    func shootButtonPressed()
    {
        println("SHOOT THEM BULLETS")
        let bullet = CCBReader.load("ShootBullet")
        bullet.position = hero.position
        bulletsLayer.addChild(bullet)
    }
    
    override func didLoadFromCCB()
    {
        super.didLoadFromCCB()
        nameOfGame = "Shoot"
        multipleTouchEnabled = true
        
        audio.preloadEffect("Audio/CorrectChime.wav")
        audio.preloadEffect("Audio/IncorrectChime.wav")
        audio.preloadEffect("Audio/ShutDownNoise.wav")
    }
    
    override func onEnter()
    {
        super.onEnter()
//        let actionFollow = CCActionFollow(target: mouseNode, worldBoundary: gamePhysicsNode.boundingBox())
//        hero.runAction(actionFollow)
        spawnNewObstacle()
//        spawnNewObstacle()
//        spawnNewObstacle()
//        spawnNewObstacle()
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent)
    {
        if(gameState == .Tutorial)
        {
            hero.positionType = CCPositionTypeMake(.Points, .Points, .BottomLeft)
        }
        super.touchBegan(touch, withEvent: event)
        if (gameState == .Playing)
        {
            sinceTouch = 0
            if(touch.locationInWorld().x < 90 && touch.locationInWorld().y < 60)
            {
                shootButtonPressed()
            }
            else
            {
                hero.position = touch.locationInNode(gamePhysicsNode)
                println(hero.position)
            }
        }
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        if (gameState == .Playing)
        {
            hero.position = touch.locationInNode(gamePhysicsNode)
            println(hero.position)
            sinceTouch = 0
        }
    }
    
    override func update(delta: CCTime)
    {
        super.update(delta)
        if(gameState == .Playing)
        {
            scrollSpeed = max(100,CGFloat(points/2+100))
            sinceTouch += delta
    
            
            if(hero.physicsBody.allowsRotation)
            {
                //limits angular velocity between -2 and 1
                let angularVelocity = clampf(Float(hero.physicsBody.angularVelocity), -2, 1)
                //set angular velocity back to angularVelocity
                hero.physicsBody.angularVelocity = CGFloat(angularVelocity)
            }
            if (sinceTouch > 0.25)
            {
                //applies the upward impulse to the spaceship after a time
                let impulse = 25000.0 * delta
                hero.physicsBody.applyAngularImpulse(CGFloat(impulse))
            }
            
            let scale = CCDirector.sharedDirector().contentScaleFactor
            gamePhysicsNode.position = ccp(round(gamePhysicsNode.position.x * scale) / scale, round(gamePhysicsNode.position.y * scale) / scale)
            hero.position = ccp(round(hero.position.x * scale) / scale, round(hero.position.y * scale) / scale)
            
            for obstacle in obstacles
            {
                //getting obstacle position on screen
                let obstacleWorldPosition = gamePhysicsNode.convertToWorldSpace(obstacle.position)
                let obstacleScreenPosition = convertToNodeSpace(obstacleWorldPosition)
                
                // obstacle moved past left side of screen?
                if obstacleScreenPosition.y < (-obstacle.contentSize.height)*2
                {
                    obstacle.removeFromParent()
                    obstacles.removeAtIndex(find(obstacles, obstacle)!)
                    
                    // for each removed obstacle, add a new one
                    spawnNewObstacle()
                }
            }
        }
    }
    
    func spawnNewObstacle()
    {
        let obstacle = CCBReader.load("ShootObstacle") as! ShootObstacle
        //set position of new obstacle
        //call Obstacle method to randomize position
        let screenWidth = CCDirector.sharedDirector().designSize.width
        let random = CGFloat(arc4random_uniform(100)) / CGFloat(100)
        let obstaclePosition = (screenWidth - 100)*random + 50
        obstacle.position = ccp(obstaclePosition, 10)
        println(obstaclePosition)
        obstacle.setString(answerString: chooseStringToPutOnCarrot())
        //add new obstacle to the physics node
        obstaclesLayer.addChild(obstacle)
        //add new obstacle to the array of obstacles
        obstacles.append(obstacle)
    }
    
    //level collision taken care of in Gameplay
    
    //detects collisions between the hero and the goal
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bullet: CCNode!, eraseBullets: CCNode!) -> Bool
    {
        bullet.removeFromParent()
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, answerBackground: CCNode!) -> Bool
    {
        if(gameState == .Playing)
        {
            hero.physicsBody.applyImpulse(CGPoint(x: 0, y: 10000))
            super.dealWithWrongAndRightAnswers(answerBackground)
            //            println("\(answer) and \(question)")
            //            println(statArray[question])
            //            var wordThing = statArray[answer] ?? WordStat(word: answer, definition: question, correctResponses: 0, wrongResponses: 0)
            ////            hero.physicsBody.velocity = CGPoint(x: hero.physicsBody.velocity.x, y: 2000)
            //            answerBackground.physicsBody = nil
            //            //println(answerBackground.name)
            //            if(answerBackground.name == answer)
            //            {
            //                println("Right Answer")
            //                self.audio.playEffect("Audio/CorrectChime.wav", volume: 0.7, pitch: 1.0, pan: 0.0, loop: false)
            //                //var wordThing = statArray[answerBackground.name] ?? WordStat(word: answerBackground.name, definition: question, correctResponses: 0, wrongResponses: 0)
            //                wordThing.correctResponses = wordThing.correctResponses + 1
            //                statArray[answer] = wordThing
            //                answerBackground.animationManager.runAnimationsForSequenceNamed("popAnswer")
            //                handleRightAnswer()
            //            }
            //            else
            //            {
            //                self.audio.playEffect("Audio/IncorrectChime.wav", volume: 1.0, pitch: 1.0, pan: 0.0, loop: false)
            //                println("Wrong Answer")
            //                //println("\(answer) and \(question)")
            //                //var wordThing = statArray[answerBackground.name] ?? WordStat(word: answerBackground.name, definition: gameData.quizWords[answerBackground.name]!, correctResponses: 0, wrongResponses: 0)
            //                wordThing.wrongResponses = wordThing.wrongResponses + 1
            //                statArray[answer] = wordThing
            //                answerBackground.animationManager.runAnimationsForSequenceNamed("wrongAnswer")
            //                handleWrongAnswer()
            //            }
        }
        return true
    }
    
    override func handleRightAnswer()
    {
        super.handleRightAnswer()
    }
    
    override func pauseForReadingQuestion()
    {
        super.pauseForReadingQuestion()
    }
    
    override func handleWrongAnswer()
    {
        super.handleWrongAnswer()
    }
}
