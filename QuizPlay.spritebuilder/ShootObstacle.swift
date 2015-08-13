//
//  ShootObstacle.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 8/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
class ShootObstacle: CCNode
{
    weak var answerLabel: CCLabelTTF!
    weak var labelBackground: CCNode!
    var fallingSpeed: Int = 30
    
    func didLoadFromCCB()
    {
        
    }
    
    func setString(#answerString: String)
    {
        answerLabel.string = answerString
        labelBackground.name = answerString
        answerLabel.fontSize = MiscMethods.getCorrectFontSizeToMatchLabel(answerLabel, maxFontSize: 30)
    }
}