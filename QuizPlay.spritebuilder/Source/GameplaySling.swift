//
//  GameplaySling.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit
import Darwin

class GameplaySling: CCNode, CCPhysicsCollisionDelegate
{
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var slingPocket: CCNode!
    weak var contentNode: CCNode!
    weak var gradientNode: CCNodeGradient!
    weak var mouseJointNode: CCNode!
    weak var launchNode: CCNode!
    weak var bar1: CCNode!
    weak var bar2: CCNode!
    weak var hero: CCSprite!
    var mouseJoint: CCPhysicsJoint?
    var actionFollow: CCActionFollow?
    var quizWords = Dictionary<String, String>()
    
    func didLoadFromCCB()
    {
        userInteractionEnabled = true
        gamePhysicsNode.collisionDelegate = self
        mouseJointNode.physicsBody.collisionMask = []
        launchNode.physicsBody.collisionMask = []
        bar1.physicsBody.collisionMask = []
        bar2.physicsBody.collisionMask = []
    }
    
    override func onEnterTransitionDidFinish()
    {
        gamePhysicsNode.debugDraw = true
    }
    
    override func update(delta: CCTime)
    {
        //var num = CDouble(10)
        let slingPocketLocation = slingPocket.convertToWorldSpace(slingPocket.position)
//        println(slingPocketLocation)
//        println("asldjf\(slingPocket.position)")
        let slingx = slingPocketLocation.x
        let slingy = slingPocketLocation.y
        if slingy < 280
        {
            let rotation = atan((160-slingx)/(280-slingy))*180/3.14
            slingPocket.rotation = Float(rotation)
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        let touchLocation = touch.locationInNode(contentNode)
        if CGRectContainsPoint(slingPocket.boundingBox(), touchLocation)
        {
            mouseJointNode.position = touchLocation
            mouseJoint = CCPhysicsJoint.connectedSpringJointWithBodyA(mouseJointNode.physicsBody, bodyB: slingPocket.physicsBody, anchorA: CGPointZero, anchorB: CGPoint(x: 150, y: 150), restLength: 0, stiffness: 6000, damping: 150)
        }
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        // whenever touches move, update the position of the mouseJointNode to the touch position
        let touchLocation = touch.locationInNode(contentNode)
        mouseJointNode.position = touchLocation
    }
    
    func releaseCatapult()
    {
        if let joint = mouseJoint
        {
            joint.invalidate()
            mouseJoint = nil
        }
        let actionFollow = CCActionFollow(target: hero, worldBoundary: gradientNode.boundingBox())
        contentNode.runAction(actionFollow)
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        releaseCatapult()
    }
    
    override func touchCancelled(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        releaseCatapult()
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
