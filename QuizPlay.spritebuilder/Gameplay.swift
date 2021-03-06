//
//  Gameplay.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 8/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import Mixpanel

class Gameplay: CCNode, CCPhysicsCollisionDelegate
{
    enum GameState
    {
        case Playing, GameOver, Tutorial, Paused, TempPaused
    }
    
    //Necessaries
    var gameState: GameState = .Tutorial
    var mixpanel = Mixpanel.sharedInstance()
    var audio = OALSimpleAudio.sharedInstance()
    var nameOfGame: String!
    var startTime: NSTimeInterval = NSDate().timeIntervalSince1970
    var startTimeForTempPauseScreen: NSTimeInterval!
    weak var tutorialScreen: CCNode!
    weak var gamePhysicsNode: CCPhysicsNode!
    var chooseGamePopup: ChooseGameScene!
    
    //Controlling question allocation
    var isWordFirst: Bool = true
    var numberOfOptions: Int = 4
    weak var questionLabel: CCLabelTTF!
    var sinceRightAnswer: Int = 0
    var gameData: GameData!
    var question: String!
    { didSet {
        questionLabel.string = question
        questionLabel.fontSize = MiscMethods.getCorrectFontSizeToMatchLabel(questionLabel, maxFontSize: 50)
    }        }
    var answer: String!
    var choices = [String]()
    var lastWordChosen: String!
    
    //Lives
    var redFlashPopup: CCNode!
    weak var numOfLivesLabel: CCLabelTTF!
    var numOfLives: Int = 4
    { didSet {
        let greenVariable = min((Float(numOfLives-1)*2/4), 0.7)
        let redVariable = min(2 - (Float(numOfLives-1)*2/4), 0.7)
        numOfLivesLabel.outlineColor = CCColor(red: redVariable, green: greenVariable, blue: 0)
        numOfLivesLabel.string = "Lives: \(numOfLives)"
    }        }
    
    //Score
    weak var scoreLabel: CCLabelTTF!
    var points: NSInteger = 0
    { didSet {
        points = max(0,points)
        scoreLabel.string = String("Score: \(points)")
    }        }
    
    //Game Over variables
    weak var GOsetNameLabel: CCLabelTTF!
    weak var GOscoreLabel: CCLabelTTF!
    var popup: FlappyGameOver!
    
    //Pause Screen
    var pausePopup: CCNode!
    weak var pauseScreen: CCNode!
    weak var tempPausesButton: CCButton!
    
    //Temp Pause for Questions
    weak var pauseToReadQuestion: CCNode!
    weak var pauseToReadExplanation: CCNode!
    weak var readQuestionLabel: CCLabelTTF!
    var numberOfRightAnswers: Int = 0
    var tempPauseDisabled: Bool = NSUserDefaults.standardUserDefaults().boolForKey("flappyTempPauseEnabled") ?? true
    { didSet {
        NSUserDefaults.standardUserDefaults().setBool(tempPauseDisabled, forKey: "flappyTempPauseEnabled")
        NSUserDefaults.standardUserDefaults().synchronize()
    }        }
    
    //collect stats
    var statArray = Dictionary<String,WordStat>()
    
    func didLoadFromCCB()
    {
        println(tempPauseDisabled)
        //assigning MainScene as the collision delegate class
        gamePhysicsNode.collisionDelegate = self
        //gamePhysicsNode.debugDraw = true
        userInteractionEnabled = true
        pauseToReadExplanation.visible = false
        pauseToReadQuestion.visible = false
        tutorialScreen.visible = true
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
        
        chooseGamePopup = CCBReader.load("ChooseGameScene") as! ChooseGameScene
        chooseGamePopup.positionType = CCPositionType(xUnit: .Normalized, yUnit: .Normalized, corner: .BottomLeft)
        chooseGamePopup.position = CGPoint(x: 0.5, y: 0.5)
        
        chooseQuestionAndAnswer()
        gamePhysicsNode.paused = true
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        if(gameState == .Tutorial)
        {
            tutorialScreen.visible = false
            gameState = .Playing
            gamePhysicsNode.paused = false
            audio.playBg("Audio/Wristbands.wav", volume: 0.2, pan: 0.0, loop: true)
        }
        if(gameState == .TempPaused && !tempPauseDisabled)
        {
            var deltaTime = NSDate().timeIntervalSince1970 - startTimeForTempPauseScreen
            if(deltaTime > 2)
            {
                gameState = .Playing
                pauseToReadQuestion.visible = false
                if(numberOfRightAnswers < 3)
                {
                    pauseToReadExplanation.visible = false
                    readQuestionLabel.string = "Read the new question!"
                }
                gamePhysicsNode.paused = false
            }
        }
    }
    
    override func update(delta: CCTime)
    {
        println(tempPauseDisabled)
        if(gameState == .TempPaused && !tempPauseDisabled)
        {
            var deltaTime = NSDate().timeIntervalSince1970 - startTimeForTempPauseScreen
            if(deltaTime > 2)
            {
                readQuestionLabel.string = "Once you're finished reading, tap to continue!"
            }
        }
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
        //        println("Choices: \(choices)")
        //        println("q: \(question) and a: \(answer)")
    }
    
    func chooseStringToPutOnCarrot() -> String
    {
        let random = Int(arc4random_uniform(UInt32(choices.count)))
        if(sinceRightAnswer > 4)
        {
            sinceRightAnswer = 0
            //            println("TOO LONG NO ANSWER")
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
                    level.physicsBody.collisionMask = []
                    level.opacity = 0.5
                    println(hero.position.y)
                    self.audio.playEffect("Audio/ShutDownNoise.wav", volume: 0.8, pitch: 1.0, pan: 0.0, loop: false)
                    self.triggerGameOver()
                }
            }, key: hero)
        return true
    }
    
    func dealWithWrongAndRightAnswers(answerBackground: CCNode!)
    {
//        println("\(answer) and \(question)")
//        println(statArray[question])
        var wordThing = statArray[answer] ?? WordStat(word: answer, definition: question, correctResponses: 0, wrongResponses: 0)
        answerBackground.physicsBody = nil
        //println(answerBackground.name)
        if(answerBackground.name == answer)
        {
//            println("Right Answer")
            self.audio.playEffect("Audio/CorrectChime.wav", volume: 0.7, pitch: 1.0, pan: 0.0, loop: false)
            wordThing.correctResponses = wordThing.correctResponses + 1
            statArray[answer] = wordThing
            answerBackground.animationManager.runAnimationsForSequenceNamed("popAnswer")
            handleRightAnswer()
        }
        else
        {
            self.audio.playEffect("Audio/IncorrectChime.wav", volume: 1.0, pitch: 1.0, pan: 0.0, loop: false)
//            println("Wrong Answer")
            wordThing.wrongResponses = wordThing.wrongResponses + 1
            statArray[answer] = wordThing
            answerBackground.animationManager.runAnimationsForSequenceNamed("wrongAnswer")
            handleWrongAnswer()
        }
    }
    
    func handleRightAnswer()
    {
        if(gameState == .Playing)
        {
            points = points + 10
            chooseQuestionAndAnswer()
            pauseForReadingQuestion()
        }
    }
    
    func pauseForReadingQuestion()
    {
        if(gameState == .Playing && !tempPauseDisabled)
        {
            startTimeForTempPauseScreen = NSDate().timeIntervalSince1970
            gameState = .TempPaused
            gamePhysicsNode.paused = true
            pauseToReadQuestion.visible = true
            if(numberOfRightAnswers < 2)
            {
                pauseToReadExplanation.visible = true
                numberOfRightAnswers++
            }
        }
    }
    
    func handleWrongAnswer()
    {
        if(gameState == .Playing)
        {
            points = points - 5
        }
    }
    
    
    //All buttons on Game Over Screen
    func downloadTheseFlashcardsButton()
    {
        var downloadsArray = NSUserDefaults.standardUserDefaults().arrayForKey("downloads") as? [Dictionary<String,String>] ?? [Dictionary<String,String>]()
        var tempDictionary = gameData.quizWords
        tempDictionary["GDidVarsha"] = gameData.id
        tempDictionary["GDtitleVarsha"] = gameData.title
        tempDictionary["GDcreatorVarsha"] = gameData.createdBy
        downloadsArray.append(tempDictionary)
        NSUserDefaults.standardUserDefaults().setObject(downloadsArray, forKey: "downloads")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    func toViewDownloadsButton()
    {
        mixpanel.track("To Another Scene", properties: ["To Scene": "Download", "From Scene": "\(nameOfGame)GameOver"])
        MiscMethods.toViewDownloadsScene()
    }
    func toSearchSetsButton()
    {
        mixpanel.track("To Another Scene", properties: ["To Scene": "Search", "From Scene": "\(nameOfGame)GameOver"])
        MiscMethods.toSearchSetScene()
    }
    func toStatScreenButton()
    {
        mixpanel.track("To Another Scene", properties: ["To Scene": "ViewStats", "From Scene": "\(nameOfGame)GameOver"])
        let scene = CCScene()
        let statScene = CCBReader.load("StatScreen") as! StatScreen
        statScene.statsArray = statArray.values.array
        statScene.gameData = gameData
        statScene.nameOfGame = nameOfGame
        scene.addChild(statScene)
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    func retryButton()
    {
        MiscMethods.toGameplayScene(gameData, nameOfGame: nameOfGame)
    }
    func switchGameButton()
    {
        chooseGamePopup.gameData = gameData
        parent.addChild(chooseGamePopup)
    }


    //Pause Screen Related Buttons
    func pauseGame()
    {
        if(gameState == .Playing)
        {
            gameState = .Paused
            gamePhysicsNode.paused = true
            parent.addChild(pausePopup)
            setTempPausesButtonTitle()
        }
    }
    func resumeGame()
    {
        parent.removeChild(pausePopup)
        gameState = .Playing
        gamePhysicsNode.paused = false
        //        println("RESUME")
    }
    func quitGame()
    {
        mixpanel.track("Quit Game", properties: ["Game Name": nameOfGame])
        triggerGameOver()
    }
    func switchBoolTempPauses()
    {
        tempPauseDisabled = !tempPauseDisabled
        setTempPausesButtonTitle()
    }
    func setTempPausesButtonTitle()
    {
        if(!tempPauseDisabled)
        {
            tempPausesButton.title = "Disable Temporary Pauses"
        }
        else
        {
            tempPausesButton.title = "Enable Temporary Pauses"
        }
    }
    
    //handles what happens when the game is over
    func triggerGameOver()
    {
        //audio.playBg("Audio/ObsidianMirror.wav", loop: true)
        numOfLives--
        redFlashPopup = CCBReader.load("RedFlash")
        redFlashPopup.positionType = CCPositionType(xUnit: .Normalized, yUnit: .Normalized, corner: .BottomLeft)
        redFlashPopup.position = CGPoint(x: 0.5, y: 0.5)
        parent.addChild(redFlashPopup)
        if(numOfLives == 0)
        {
            mixpanel.track("Game Over", properties: ["Score Level": Int(Float(points)/20), "Raw Score": points, "Game Name": nameOfGame])
            audio.playBg("Audio/ObsidianMirror.wav", volume: 0.3, pan: 0.0, loop: true)
            gameState = .GameOver
            GOscoreLabel.string = "Score: \(points)"
            GOsetNameLabel.string = "Quiz Played: \(gameData.title)"
            parent.addChild(popup)
        }
        //        println("POPUP")
    }
}

//    func switchQAndAButton()
//    {
//        isWordFirst = !isWordFirst
//        //chooseQuestionAndAnswer()
//    }


