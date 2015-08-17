//
//  GameplayShoot.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 8/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import Mixpanel
import CoreMotion

class ShootGameplay: Gameplay
{
    enum GameState
    {
        case Playing, GameOver, Tutorial, Paused, TempPaused
    }
    
    weak var hero: CCSprite!
    var heroMaxSpeed: CGFloat = 300
    weak var obstaclesLayer: CCNode!
    weak var bulletsLayer: CCNode!
    weak var buttonNode: CCNode!
    
    var sinceTouch: CCTime = 0
    var scrollSpeed: CGFloat = 80
    
    var obstacles: [CCNode] = [] //array of obstacles
    var bullets: [CCNode] = []
    let firstObstaclePosition : CGFloat = 100
    let distanceBetweenObstacles : CGFloat = 230
    
    var motionManager: CMMotionManager! = CMMotionManager()
    
    override func didLoadFromCCB()
    {
        super.didLoadFromCCB()
        nameOfGame = "Shoot"
        multipleTouchEnabled = true
        
        audio.preloadEffect("Audio/CorrectChime.wav")
        audio.preloadEffect("Audio/IncorrectChime.wav")
        audio.preloadEffect("Audio/ShutDownNoise.wav")
        
        motionManager.startAccelerometerUpdates()
    }
    
    override func onEnter()
    {
        super.onEnter()
//        let actionFollow = CCActionFollow(target: mouseNode, worldBoundary: gamePhysicsNode.boundingBox())
//        hero.runAction(actionFollow)
        spawnNewObstacle()
        spawnNewObstacle()
        spawnNewObstacle()
        spawnNewObstacle()
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent)
    {
        if (gameState == .Tutorial)
        {
            hero.positionType = CCPositionTypeMake(.Points, .Points, .BottomLeft)
        }
        super.touchBegan(touch, withEvent: event)
        if (gameState == .Playing)
        {
            sinceTouch = 0
            println("\(touch.locationInNode(gamePhysicsNode)) and \(touch.locationInWorld())")
            if(touch.locationInWorld().y > 60)
            {
                hero.position = touch.locationInNode(gamePhysicsNode)
            }
            else
            {
                shootButtonPressed()
            }
        }
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        if (gameState == .Playing)
        {
            if(touch.locationInWorld().y > 60)
            {
                hero.position = touch.locationInNode(gamePhysicsNode)
            }
        }
    }
    
    override func update(delta: CCTime)
    {
        super.update(delta)
        if(gameState == .Playing)
        {
            scrollSpeed = max(100,CGFloat(points+100))
            sinceTouch += delta
    
            if hero.position.x > CCDirector.sharedDirector().designSize.width
            {
                hero.position.x = CCDirector.sharedDirector().designSize.width
            }
            if hero.position.x < 0
            {
                hero.position.x = 0
            }
            
//            if(hero.physicsBody.allowsRotation)
//            {
//                //limits angular velocity between -2 and 1
//                let angularVelocity = clampf(Float(hero.physicsBody.angularVelocity), -2, 1)
//                //set angular velocity back to angularVelocity
//                hero.physicsBody.angularVelocity = CGFloat(angularVelocity)
//            }
//            if (sinceTouch > 0.25)
//            {
//                //applies the upward impulse to the spaceship after a time
//                let impulse = 25000.0 * delta
//                hero.physicsBody.applyAngularImpulse(CGFloat(impulse))
//            }
            
//            if let accelerometerData: CMAccelerometerData = motionManager.accelerometerData
//            {
//                let acceleration: CMAcceleration = accelerometerData.acceleration
//                let accelFloat: CGFloat = CGFloat(acceleration.x)
//                
//                //
//                var newXVel: CGFloat = hero.physicsBody.velocity.x + accelFloat*2000.0*CGFloat(delta)
//                hero.physicsBody.velocity.x = min(max(newXVel, -heroMaxSpeed), heroMaxSpeed)
//            }
            
            hero.position = ccp(hero.position.x, hero.position.y + scrollSpeed * CGFloat(delta))
            gamePhysicsNode.position = ccp(gamePhysicsNode.position.x, gamePhysicsNode.position.y - scrollSpeed * CGFloat(delta))
            //rounds the physics node to the nearest int to prevent black line artifact / fixes that one problem
            let scale = CCDirector.sharedDirector().contentScaleFactor
            gamePhysicsNode.position = ccp(round(gamePhysicsNode.position.x * scale) / scale, round(gamePhysicsNode.position.y * scale) / scale)
            hero.position = ccp(round(hero.position.x * scale) / scale, round(hero.position.y * scale) / scale)
            
            for obstacle in obstacles
            {
                //getting obstacle position on screen
                let obstacleWorldPosition = gamePhysicsNode.convertToWorldSpace(obstacle.position)
                let obstacleScreenPosition = convertToNodeSpace(obstacleWorldPosition)
                
                // obstacle moved past bottom of screen?
                if obstacleScreenPosition.y < (-obstacle.contentSize.height)*2
                {
                    obstacle.removeFromParent()
                    obstacles.removeAtIndex(find(obstacles, obstacle)!)
                    
                    // for each removed obstacle, add a new one
                    spawnNewObstacle()
                }
            }
            
            for bullet in bullets
            {
                //getting obstacle position on screen
                let bulletWorldPosition = gamePhysicsNode.convertToWorldSpace(bullet.position)
                let bulletScreenPosition = convertToNodeSpace(bulletWorldPosition)
                
//                println(bulletScreenPosition)
                // obstacle moved past bottom of screen?
                if bulletScreenPosition.y > CCDirector.sharedDirector().designSize.height
                {
                    bullet.removeFromParent()
                    bullets.removeAtIndex(find(bullets, bullet)!)
                }
            }
        }
    }
    
    func spawnNewObstacle()
    {
        var prevObstaclePos = firstObstaclePosition
        //previous position set to position of the last one
        if obstacles.count > 0
        {
            prevObstaclePos = obstacles.last!.position.y
        }
        let obstacle = CCBReader.load("ShootObstacle") as! ShootObstacle
        //set position of new obstacle
        //call Obstacle method to randomize position
        let screenWidth = CCDirector.sharedDirector().designSize.width
        let screenHeight = CCDirector.sharedDirector().designSize.height
        let random = CGFloat(arc4random_uniform(100)) / CGFloat(100)
        let obstaclePosition = (screenWidth - 100)*random + 50
        obstacle.position = ccp(obstaclePosition, prevObstaclePos + distanceBetweenObstacles)
//        println("\(prevObstaclePos) and \(obstacle.position)")
        obstacle.setString(answerString: chooseStringToPutOnCarrot())
        //add new obstacle to the physics node
        obstaclesLayer.addChild(obstacle)
        //add new obstacle to the array of obstacles
        obstacles.append(obstacle)
    }
    
    func shootButtonPressed()
    {
        if(gameState == .Playing)
        {
            println("SHOOT THEM BULLETS")
            let bullet = CCBReader.load("ShootBullet")
            bullet.position = hero.position
            bullets.append(bullet)
            bulletsLayer.addChild(bullet)
        }
    }
    
    //level collision taken care of in Gameplay
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, bullet: CCNode!, answerBackground: CCNode!) -> Bool
    {
        if(gameState == .Playing)
        {
            bullet.removeFromParent()
            bullets.removeAtIndex(find(bullets, bullet)!)
            super.dealWithWrongAndRightAnswers(answerBackground)
        }
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, answerBackground: CCNode!) -> Bool
    {
        if(gameState == .Playing)
        {
            gameState = .GameOver
            hero.physicsBody.applyImpulse(CGPoint(x: 0, y: 1000))
            hero.physicsBody.applyAngularImpulse(CGFloat(100))
            triggerGameOver()
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
    
    override func onExit()
    {
        motionManager.stopAccelerometerUpdates()
        super.onExit()
    }
}
