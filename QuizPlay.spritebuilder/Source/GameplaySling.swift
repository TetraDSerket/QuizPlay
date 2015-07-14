//
//  GameplaySling.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class GameplaySling: CCNode, CCPhysicsCollisionDelegate
{
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var slingPocket: CCNode!
    weak var contentNode: CCNode!
    weak var mouseJointNode: CCNode!
    weak var hero: CCSprite!
    var mouseJoint: CCPhysicsJoint?
    var actionFollow: CCActionFollow?
    var quizWords = Dictionary<String, String>()
    
    func didLoadFromCCB()
    {
        userInteractionEnabled = true
        gamePhysicsNode.collisionDelegate = self
        mouseJointNode.physicsBody.collisionMask = []

    }
    
    override func onEnterTransitionDidFinish()
    {
        let actionFollow = CCActionFollow(target: hero, worldBoundary: boundingBox())
        contentNode.runAction(actionFollow)
        gamePhysicsNode.debugDraw = true
    }
    
    override func update(delta: CCTime)
    {
        slingPocket.physicsBody.velocity.x = 0
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        let touchLocation = touch.locationInNode(contentNode)
        if CGRectContainsPoint(slingPocket.boundingBox(), touchLocation)
        {
            mouseJointNode.position = touchLocation
            mouseJoint = CCPhysicsJoint.connectedSpringJointWithBodyA(mouseJointNode.physicsBody, bodyB: slingPocket.physicsBody, anchorA: CGPointZero, anchorB: CGPoint(x: 150, y: 150), restLength: 0, stiffness: 3000, damping: 150)
            
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
            // releases the joint and lets the catapult snap back
            joint.invalidate()
            mouseJoint = nil
        }
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
