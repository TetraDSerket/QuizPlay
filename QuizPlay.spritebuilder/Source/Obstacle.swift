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
    
    let topCarrotMinimumPositionY : CGFloat = 80
    let bottomCarrotMaximumPositionY : CGFloat = 350
    let carrotDistance : CGFloat = 130
    
    func didLoadFromCCB()
    {
        //add sensors to the two carrots
        topCarrot.physicsBody.sensor = true
        bottomCarrot.physicsBody.sensor = true
    }
    
    func setupRandomPosition()
    {
        //random number generator
        let randomPrecision : UInt32 = 100
        //make random//float of//random# 0 to randomPrecision    //divide by 100 to get percentage
        let random = CGFloat(arc4random_uniform(randomPrecision)) / CGFloat(randomPrecision)
        let range = bottomCarrotMaximumPositionY - carrotDistance - topCarrotMinimumPositionY
        //set top and bottom carrots to position
        topCarrot.position = ccp(topCarrot.position.x, topCarrotMinimumPositionY + (random * range));
        bottomCarrot.position = ccp(bottomCarrot.position.x, topCarrot.position.y + carrotDistance);
    }
    
    func setString(#answerString: String)
    {
        answerLabel.string = answerString
        let length = count(answerLabel.string)
        if(length > 13)
        {
            answerLabel.fontSize = CGFloat(12)
            answerLabel.adjustsFontSizeToFit = false
        }
        if(length > 16)
        {
            answerLabel.fontSize = CGFloat(9)
        }
    }
}

