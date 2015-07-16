//
//  GameplayFlappy.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class GameplayFlappy: CCScene, CCPhysicsCollisionDelegate
{
    var isWordFirst: Bool = true //if true, the word will be first and the definition afterwards in the Dictionary
    var numberOfOptions: Int = 4
    
    weak var hero: CCSprite!
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var ground1: CCSprite!
    weak var ground2: CCSprite!
    weak var obstaclesLayer: CCNode!
    weak var restartButton: CCButton!
    weak var scoreLabel: CCLabelTTF!
    weak var questionLabel: CCLabelTTF!
    var sinceTouch: CCTime = 0
    var scrollSpeed: CGFloat = 80
    var quizWords = Dictionary<String, String>()
    var question: String!
    {
        didSet
        {
            questionLabel.string = question
        }
    }
    var answer: String!
    var choices = [String]()
    var grounds = [CCSprite]() //array for the ground sprites
    var obstacles : [CCNode] = [] //array of obstacles
    let firstObstaclePosition : CGFloat = 280
    let distanceBetweenObstacles : CGFloat = 160
    var gameOver = false
    var points: NSInteger = 0
    {
        didSet
        {
            scoreLabel.string = String(points)
        }
    }
    
    
    func didLoadFromCCB() //what happens first, right when the app starts?
    {
        initializeQuizWordsArray()
        chooseQuestionAndAnswer()
        println("\(choices) and \(question)")
        println("Answer is: \(answer)")
        userInteractionEnabled = true
        //add the two grounds to the ground array
        grounds.append(ground1)
        grounds.append(ground2)
        
        //create three obstacles that will start off the infinite creation system
        spawnNewObstacle()
        spawnNewObstacle()
        spawnNewObstacle()
        
        //assigning MainScene as the collision delegate class
        gamePhysicsNode.collisionDelegate = self
        //gamePhysicsNode.debugDraw = true
    }
    
    func chooseQuestionAndAnswer()
    {
        var tempQuizWords = quizWords
        if isWordFirst
        {
            for index in 0..<numberOfOptions
            {
                //let random = arc4random_uniform(UInt32(numberOfOptions))
                if(index == 0)
                {
                    //a random key is put into the question variable and its pair is put into the answer, then both are removed from the temp dictionary
                    let random = Int(arc4random_uniform(UInt32(tempQuizWords.count)))
                    answer = Array(tempQuizWords.keys)[random]
                    question = tempQuizWords[answer]!
                    choices.append(answer)
                    tempQuizWords.removeValueForKey(answer)
                }
                else
                {
                    let random = Int(arc4random_uniform(UInt32(tempQuizWords.count)))
                    let key = Array(tempQuizWords.keys)[random]
                    choices.append(key)
                }
            }
        }
        else //if definition first is chosen
        {
            for index in 0..<numberOfOptions
            {
                if(index == 0)
                {
                    let random = Int(arc4random_uniform(UInt32(tempQuizWords.count)))
                    question = Array(tempQuizWords.keys)[random]
                    answer = tempQuizWords[question]!
                    choices.append(answer)
                    tempQuizWords.removeValueForKey(question)
                }
                else
                {
                    let random = Int(arc4random_uniform(UInt32(tempQuizWords.count)))
                    let key = Array(tempQuizWords.keys)[random]
                    choices.append(tempQuizWords[key]!)
                }
            }

        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent)
    {
        if (gameOver == false)
        {
            hero.physicsBody.applyImpulse(ccp(0, 300))
            hero.physicsBody.applyAngularImpulse(10000)
            sinceTouch = 0
        }
    }
    
    override func update(delta: CCTime)
    {
        //limits velocity between -infinity and 200
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        //sets velocity back to the limited velocity
        hero.physicsBody.velocity = ccp(0,CGFloat(velocityY))
        
        //change in time
        sinceTouch += delta
        //limit position between 30 degrees up and 90 down
        hero.rotation = clampf(hero.rotation, -30, 90)
        if(hero.physicsBody.allowsRotation)
        {
            //limits angular velocity between -2 and 1
            let angularVelocity = clampf(Float(hero.physicsBody.angularVelocity), -2, 1)
            //set angular velocity back to angularVelocity
            hero.physicsBody.angularVelocity = CGFloat(angularVelocity)
        }
        if (sinceTouch > 0.3)
        {
            //applies the downwards impulse to the bunny after a time
            let impulse = -18000.0 * delta
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
            if obstacleScreenPosition.x < (-obstacle.contentSize.width)
            {
                obstacle.removeFromParent()
                obstacles.removeAtIndex(find(obstacles, obstacle)!)
                
                // for each removed obstacle, add a new one
                spawnNewObstacle()
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
    
    func chooseStringToPutOnCarrot() -> String
    {
        let random = Int(arc4random_uniform(UInt32(choices.count)))
        return choices[random]
    }
    
    //detects collisions between hero and level items, which were defined in SpriteBuilder
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, level: CCNode!) -> Bool
    {
        triggerGameOver()
        return true
    }
    
    //detects collisions between the hero and the goal
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, goal: CCNode!) -> Bool
    {
        //remove goal so no duplicate scoring
        goal.removeFromParent()
        points++
        return true
    }
    
    //detects collisions between the hero and an answer carrot
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, answerCarrot: CCNode!) -> Bool
    {
        let answerLabel = answerCarrot.children[0] as! CCLabelTTF
        if(answerLabel.string == answer)
        {
            handleRightAnswer()
        }
        else
        {
            handleWrongAnswer()
        }
        return true
    }
    
    func handleRightAnswer()
    {
        println("YOU WON YAY")
        chooseQuestionAndAnswer()
    }
    
    func handleWrongAnswer()
    {
        println("You ARE WRONG VERY WRONG")
    }
    
    //restarts game
    func restart()
    {
        let scene = CCBReader.loadAsScene("GameplayFlappy")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    
    //handles what happens when the game is over
    func triggerGameOver()
    {
        if (gameOver == false)
        {
            gameOver = true
            restartButton.visible = true
            scrollSpeed = 0
            hero.rotation = 90
            hero.physicsBody.allowsRotation = false
            
            // just in case
            hero.stopAllActions()
            
            //makes a sequence that shakes the screen up and down (switch to 4,0 for side to side
            let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0, 4)))
            let moveBack = CCActionEaseBounceOut(action: move.reverse())
            let shakeSequence = CCActionSequence(array: [move, moveBack])
            runAction(shakeSequence)
        }
        
    }
    
    func initializeQuizWordsArray()
    {
        quizWords["Gaius"] = "Stealing candy from a baby is actually really hard"
        quizWords["Henry"] = "Oh boy oh boy oh boy are we gonna kill people?"
        quizWords["Keladry"] = "Be like stone. Pretty and smooth, but able to bash someone's head in"
        quizWords["Inkling"] = "To be a kid or to be a squid, that is the question"
        quizWords["Mario"] = "It's-a me, ____"
        quizWords["Sakurai"] = "Lol take this Roy"
        quizWords["Gandalf"] = "FLY YOU FOOLS"
        quizWords["Hagrid"] = "yer a wizard harry"
    }

}
