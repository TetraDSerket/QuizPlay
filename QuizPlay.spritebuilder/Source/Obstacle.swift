//
//  Obstacle.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit
import Foundation

class Obstacle : CCNode
{
    //defining the carrot pictures
    weak var topCarrot : CCNode!
    weak var bottomCarrot : CCNode!
    weak var answerLabel: CCLabelTTF!
    weak var labelBackground: CCNodeColor!
    weak var positionNode: CCNode!
    
//    let topCarrotMinimumPositionY : CGFloat = 80
//    let bottomCarrotMaximumPositionY : CGFloat = 350
//    let carrotDistance : CGFloat = 130
    let range: CGFloat = 200
    let startingPoint: CGFloat = -80
    let randomPrecision : UInt32 = 100
    
    func didLoadFromCCB()
    {
        //add sensors to the two carrots
        topCarrot.physicsBody.sensor = true
        bottomCarrot.physicsBody.sensor = true
        labelBackground.physicsBody.sensor = true
    }
    
    func setupRandomPosition()
    {
        let random = CGFloat(arc4random_uniform(randomPrecision)) / CGFloat(randomPrecision)
        self.position = ccp(self.position.x, startingPoint + (random*range));
    }
    
    func setString(#answerString: String)
    {
        answerLabel.string = answerString
        labelBackground.name = answerString
//        let length = count(answerLabel.string)
//        if(length > 13)
//        {
//            answerLabel.fontSize = CGFloat(12)
//            answerLabel.adjustsFontSizeToFit = false
//        }
//        if(length > 16)
//        {
//            answerLabel.fontSize = CGFloat(9)
//        }
    }
}

