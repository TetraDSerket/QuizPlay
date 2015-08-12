//
//  GameplayFlappy.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import Mixpanel

class GameplayFlappy: Gameplay
{
    enum GameState
    {
        case Playing, GameOver, Tutorial, Paused, TempPaused
    }
    
    weak var hero: CCSprite!
    weak var ground1: CCSprite!
    weak var ground2: CCSprite!
    weak var obstaclesLayer: CCNode!

    weak var tutorialScreen: CCNode!
    var sinceTouch: CCTime = 0
    var scrollSpeed: CGFloat = 80

    var grounds = [CCSprite]() //array for the ground sprites
    var obstacles : [CCNode] = [] //array of obstacles
    let firstObstaclePosition : CGFloat = 100
    let distanceBetweenObstacles : CGFloat = 180
    
    override func didLoadFromCCB()
    {
        super.didLoadFromCCB()
        nameOfGame = "Flappy"
        //add the two grounds to the ground array
        grounds.append(ground1)
        grounds.append(ground2)
    
        audio.preloadEffect("Audio/CorrectChime.wav")
        audio.preloadEffect("Audio/IncorrectChime.wav")
        audio.preloadEffect("Audio/ShutDownNoise.wav")
//        //assigning MainScene as the collision delegate class
//        gamePhysicsNode.collisionDelegate = self
//        //gamePhysicsNode.debugDraw = true
//        userInteractionEnabled = true
    }
    
    override func onEnter()
    {
        super.onEnter()
//        popup = CCBReader.load("FlappyGameOver", owner: self) as! FlappyGameOver
//        popup.positionType = CCPositionType(xUnit: .Normalized, yUnit: .Normalized, corner: .BottomLeft)
//        popup.position = CGPoint(x: 0.5, y: 0.5)
//        
//        pausePopup = CCBReader.load("PauseScreen", owner: self)
//        pausePopup.positionType = CCPositionType(xUnit: .Normalized, yUnit: .Normalized, corner: .BottomLeft)
//        pausePopup.position = CGPoint(x: 0.5, y: 0.5)
//        
//        chooseQuestionAndAnswer()
//        gamePhysicsNode.paused = true

        spawnNewObstacle()
        spawnNewObstacle()
        spawnNewObstacle()
        spawnNewObstacle()
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent)
    {
        super.touchBegan(touch, withEvent: event)
        if(gameState == .Tutorial)
        {
            gameState = .Playing
            hero.positionType = CCPositionTypeMake(.Points, .Points, .BottomLeft)
            gamePhysicsNode.paused = false
            audio.playBg("Audio/Wristbands.wav", volume: 0.2, pan: 0.0, loop: true)
        }
        if (gameState == .Playing)
        {
            tutorialScreen.visible = false
            hero.physicsBody.applyImpulse(ccp(0, 3000))
            hero.physicsBody.applyAngularImpulse(-5000)
            sinceTouch = 0
        }
        
    }
    
    override func update(delta: CCTime)
    {
        super.update(delta)
        if(gameState == .Playing)
        {
            scrollSpeed = max(100,CGFloat(points/2+100))
            
            //limits velocity between -infinity and 200
            let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 150)
            //sets velocity back to the limited velocity
            hero.physicsBody.velocity = ccp(0,CGFloat(velocityY))
            
            //change in time
            sinceTouch += delta
            //limit position between 30 degrees up and 90 down
            hero.rotation = clampf(hero.rotation, -20, 20)
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
            
            //moves hero to the right
            //multiplying by delta ensures that the hero moves at the same speed, no matter the frame rate
            hero.position = ccp(hero.position.x + scrollSpeed * CGFloat(delta), hero.position.y)
            //moves physics node (camera) to the left
            gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - scrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)
            //rounds the physics node to the nearest int to prevent black line artifact / fixes that one problem
            let scale = CCDirector.sharedDirector().contentScaleFactor
            gamePhysicsNode.position = ccp(round(gamePhysicsNode.position.x * scale) / scale, round(gamePhysicsNode.position.y * scale) / scale)
            hero.position = ccp(round(hero.position.x * scale) / scale, round(hero.position.y * scale) / scale)
            
            //loop ground whenever the ground image is moved completely off the stage
            //go through grounds array
            for ground in grounds
            {
                //get the position of the ground on the world, and then on the screen
                let groundWorldPosition = gamePhysicsNode.convertToWorldSpace(ground.position)
                let groundScreenPosition = convertToNodeSpace(groundWorldPosition)
                //if the x-position of the side of the ground is less than the width of the ground (if its off screen)
                if groundScreenPosition.x <= (-ground.contentSize.width * CGFloat(ground.scaleX))
                {
                    //move the ground two ground-widths to the right
                    ground.position = ccp(ground.position.x + ground.contentSize.width * CGFloat(ground.scaleX) * 2 - 10, ground.position.y)
                }
            }
            
            for obstacle in obstacles
            {
                //getting obstacle position on screen
                let obstacleWorldPosition = gamePhysicsNode.convertToWorldSpace(obstacle.position)
                let obstacleScreenPosition = convertToNodeSpace(obstacleWorldPosition)
                
                // obstacle moved past left side of screen?
                if obstacleScreenPosition.x < (-obstacle.contentSize.width)*2
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
        //first obstacle will be at firstObstaclePosition
        var prevObstaclePos = firstObstaclePosition
        //previous position set to position of the last one
        if obstacles.count > 0
        {
            prevObstaclePos = obstacles.last!.position.x
        }
        
        // create and add a new obstacle, cast as Obstacle
        let obstacle = CCBReader.load("Obstacle") as! Obstacle
        //set position of new obstacle
        obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 0)
        //call Obstacle method to randomize position
        obstacle.setupRandomPosition()
        obstacle.setString(answerString: chooseStringToPutOnCarrot())
        //add new obstacle to the physics node
        obstaclesLayer.addChild(obstacle)
        //add new obstacle to the array of obstacles
        obstacles.append(obstacle)
    }
    
    //level collision taken care of in Gameplay
    
    //detects collisions between the hero and the goal
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, goal: CCNode!) -> Bool
    {
        //remove goal so no duplicate scoring
        goal.removeFromParent()
        if(gameState == .Playing)
        {
            //points++
        }
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
    
    func retryButton()
    {
        let scene = CCScene()
        let flappyScene = CCBReader.load("GameplayFlappy") as! GameplayFlappy
        flappyScene.gameData = gameData
        scene.addChild(flappyScene)
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
}


//        if (gameOver == false)
//        {
//            gameOver = true
//            scrollSpeed = 0
//            hero.rotation = 90
//            hero.physicsBody.allowsRotation = false
//
//            // just in case
//            hero.stopAllActions()

//makes a sequence that shakes the screen up and down (switch to 4,0 for side to side
//            let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0, 4)))
//            let moveBack = CCActionEaseBounceOut(action: move.reverse())
//            let shakeSequence = CCActionSequence(array: [move, moveBack])
//            runAction(shakeSequence)
