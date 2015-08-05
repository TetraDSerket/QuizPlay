//
//  GameplayFlappy.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import Mixpanel

class GameplayFlappy: CCNode, CCPhysicsCollisionDelegate
{
    enum GameState
    {
        case Playing, GameOver, Tutorial, Paused
    }
    
    var mixpanel = Mixpanel.sharedInstance()
    var isWordFirst: Bool = true//if true, the word will be first and the definition afterwards in the Dictionary
    var numberOfOptions: Int = 4
    
    weak var hero: CCSprite!
    var gameState: GameState = .Tutorial
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var ground1: CCSprite!
    weak var ground2: CCSprite!
    weak var obstaclesLayer: CCNode!
    weak var scoreLabel: CCLabelTTF!
    weak var GOsetNameLabel: CCLabelTTF!
    weak var GOscoreLabel: CCLabelTTF!
    weak var questionLabel: CCLabelTTF!
    weak var tutorialScreen: CCNode!
    weak var pauseScreen: CCNode!
    var statArray = Dictionary<String,WordStat>()
    var popup: FlappyGameOver!
    var pausePopup: CCNode!
    var sinceTouch: CCTime = 0
    var sinceRightAnswer: Int = 0
    var scrollSpeed: CGFloat = 80
    var gameData: GameData!
    //var quizWords = Dictionary<String, String>()
    var question: String!
    {
        didSet
        {
            questionLabel.string = question
            questionLabel.fontSize = MiscMethods.getCorrectFontSizeToMatchLabel(questionLabel, maxFontSize: 50)
        }
    }
    var answer: String!
    var choices = [String]()
    var lastWordChosen: String!
    var grounds = [CCSprite]() //array for the ground sprites
    var obstacles : [CCNode] = [] //array of obstacles
    let firstObstaclePosition : CGFloat = 100
    let distanceBetweenObstacles : CGFloat = 180
    var gameOver = false
    var points: NSInteger = 0
    {
        didSet
        {
            points = max(0,points)
            scoreLabel.string = String("Score: \(points)")
        }
    }
    var audio = OALSimpleAudio.sharedInstance()
    
    func didLoadFromCCB()
    {
        //add the two grounds to the ground array
        grounds.append(ground1)
        grounds.append(ground2)
    
        audio.preloadEffect("Audio/CorrectChime.wav")
        audio.preloadEffect("Audio/IncorrectChime.wav")
        audio.preloadEffect("Audio/ShutDownNoise.wav")
        //assigning MainScene as the collision delegate class
        gamePhysicsNode.collisionDelegate = self
        //gamePhysicsNode.debugDraw = true
        userInteractionEnabled = true
    }
    
    override func onEnter()
    {
        super.onEnter()
        
        popup = CCBReader.load("FlappyGameOver", owner: self) as! FlappyGameOver
        popup.positionType = CCPositionType(xUnit: .Normalized, yUnit: .Normalized, corner: .BottomLeft)
        popup.position = CGPoint(x: 0.5, y: 0.5)
        
        pausePopup = CCBReader.load("PauseScreen", owner: self)
        pausePopup.positionType = CCPositionType(xUnit: .Normalized, yUnit: .Normalized, corner: .BottomLeft)
        pausePopup.position = CGPoint(x: 0.5, y: 0.5)
        
        chooseQuestionAndAnswer()
        gamePhysicsNode.paused = true

        spawnNewObstacle()
        spawnNewObstacle()
        spawnNewObstacle()
        spawnNewObstacle()
    }
    
    func chooseQuestionAndAnswer()
    {
        if(gameData.quizWords.count == 1)
        {
            var newWord = "Please choose another set"
            var newDef = "You can't play this game with a set that only has one flashcard"
            gameData.quizWords[newWord] = newDef
        }
        var tempQuizWords = gameData.quizWords
        println(tempQuizWords)
        choices = []
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
                    lastWordChosen = answer
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
                    lastWordChosen = answer
                }
                else
                {
                    let random = Int(arc4random_uniform(UInt32(tempQuizWords.count)))
                    let key = Array(tempQuizWords.keys)[random]
                    choices.append(tempQuizWords[key]!)
                }
            }

        }
        println("Choices: \(choices)")
        println("q: \(question) and a: \(answer)")
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent)
    {
        if(gameState == .Tutorial)
        {
            gameState = .Playing
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
        if(gameState == .Playing)
        {
            scrollSpeed = max(80,CGFloat(points/2+80))
            
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
    
    func chooseStringToPutOnCarrot() -> String
    {
        let random = Int(arc4random_uniform(UInt32(choices.count)))
        if(sinceRightAnswer > 4)
        {
            sinceRightAnswer = 0
            println("TOO LONG NO ANSWER")
            return answer
        }
        if choices[random] != lastWordChosen
        {
            lastWordChosen = choices[random]
            if(choices[random] == answer)
            {
                sinceRightAnswer = 0
            }
            else
            {
                sinceRightAnswer++
            }
            return choices[random]
        }
        else
        {
            return chooseStringToPutOnCarrot()
        }
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, level: CCNode!) -> Bool
    {
        gamePhysicsNode.space.addPostStepBlock(
        { () -> Void in
            if(self.gameState == .Playing)
            {
                self.audio.playEffect("Audio/ShutDownNoise.wav", volume: 0.8, pitch: 1.0, pan: 0.0, loop: false)
                self.triggerGameOver()
            }
        }, key: hero)
        return true
    }
    
    //detects collisions between the hero and the goal
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, goal: CCNode!) -> Bool
    {
        //remove goal so no duplicate scoring
        goal.removeFromParent()
        if(gameState == .Playing)
        {
            points++
        }
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, answerBackground: CCNode!) -> Bool
    {
        if(gameState == .Playing)
        {
            answerBackground.physicsBody = nil
            //println(answerBackground.name)
            if(answerBackground.name == answer)
            {
                self.audio.playEffect("Audio/CorrectChime.wav", volume: 0.7, pitch: 1.0, pan: 0.0, loop: false)
                var wordThing = statArray[answerBackground.name] ?? WordStat(word: answerBackground.name, definition: question, correctResponses: 0, wrongResponses: 0)
                wordThing.correctResponses = wordThing.correctResponses + 1
                statArray[answerBackground.name] = wordThing
                answerBackground.animationManager.runAnimationsForSequenceNamed("popAnswer")
                handleRightAnswer()
            }
            else
            {
                self.audio.playEffect("Audio/IncorrectChime.wav", volume: 1.0, pitch: 1.0, pan: 0.0, loop: false)
                var wordThing = statArray[answerBackground.name] ?? WordStat(word: answerBackground.name, definition: gameData.quizWords[answerBackground.name]!, correctResponses: 0, wrongResponses: 0)
                wordThing.wrongResponses = wordThing.wrongResponses + 1
                statArray[answerBackground.name] = wordThing
                answerBackground.animationManager.runAnimationsForSequenceNamed("wrongAnswer")
                handleWrongAnswer()
            }
        }
        return true
    }
    
    func handleRightAnswer()
    {
        if(gameState == .Playing)
        {
            println("YOU WON YAY")
            points = points + 10
            chooseQuestionAndAnswer()
        }
    }
    
    func handleWrongAnswer()
    {
        if(gameState == .Playing)
        {
            points = points - 5
            println("You ARE WRONG VERY WRONG")
        }
    }
    
    //restarts game restart button remove or change this
    func retryButton()
    {
        let scene = CCScene()
        let flappyScene = CCBReader.load("GameplayFlappy") as! GameplayFlappy
        flappyScene.gameData = gameData
        scene.addChild(flappyScene)
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    
    func toViewDownloadsButton()
    {
        mixpanel.track("To Another Scene", properties: ["To Scene": "Download", "From Scene": "GameOver"])
        MiscMethods.toViewDownloadsScene()
    }
    
    func toSearchSetsButton()
    {
        mixpanel.track("To Another Scene", properties: ["To Scene": "Search", "From Scene": "GameOver"])
        MiscMethods.toSearchSetScene()
    }
    
    func toStatScreenButton()
    {
        mixpanel.track("To Another Scene", properties: ["To Scene": "ViewStats", "From Scene": "GameOver"])
        let scene = CCScene()
        let statScene = CCBReader.load("StatScreen") as! StatScreen
        statScene.statsArray = statArray.values.array
        statScene.gameData = gameData
        scene.addChild(statScene)
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    
    func pauseGame()
    {
        if(gameState == .Playing)
        {
            gameState = .Paused
            gamePhysicsNode.paused = true
            parent.addChild(pausePopup)
            println("POPUP")
        }
    }
    
    func resumeGame()
    {
        parent.removeChild(pausePopup)
        gameState = .Playing
        gamePhysicsNode.paused = false
        println("RESUME")
    }
    
    func switchQAndAButton()
    {
        isWordFirst = !isWordFirst
        //chooseQuestionAndAnswer()
    }
    
    func quitGame()
    {
        mixpanel.track("Quit Game")
        triggerGameOver()
    }
    
    //handles what happens when the game is over
    func triggerGameOver()
    {
        //audio.playBg("Audio/ObsidianMirror.wav", loop: true)
        mixpanel.track("Game Over", properties: ["Score Level": Int(Float(points)/20), "Raw Score": points])
        audio.playBg("Audio/ObsidianMirror.wav", volume: 0.3, pan: 0.0, loop: true)
        gameState = .GameOver
        GOscoreLabel.string = "Score: \(points)"
        GOsetNameLabel.string = "Quiz Played: \(gameData.title)"
        parent.addChild(popup)
        println("POPUP")
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
