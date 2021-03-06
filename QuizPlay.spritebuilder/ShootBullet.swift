//
//  ShootBullet.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 8/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class ShootBullet: CCSprite
{
    let bulletVelocity: Int = 500
    
    func didLoadFromCCB()
    {
        self.physicsBody.sensor = true
        self.physicsBody.velocity = CGPoint(x: 0, y: bulletVelocity)
    }
}