//
//  MiscMethods.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class MiscMethods: CCNode
{
    static func getCorrectFontSizeToMatchLabel(label: CCLabelTTF, maxFontSize: Int) -> CGFloat
    {
        var fontSize = maxFontSize
        for fontSize; fontSize > 2; fontSize = fontSize-2
        {
            var string = NSString(string: label.string)
            var font = UIFont(name: label.fontName, size: CGFloat(fontSize))
            let attrs: [NSObject : AnyObject]? = [ NSFontAttributeName : font! ]
            var size = string.boundingRectWithSize( CGSizeMake(label.dimensions.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrs, context:nil).size
            if(size.height < label.dimensions.height)
            {
                return CGFloat(fontSize)
            }
        }
        return CGFloat(fontSize)
    }
    
//    static func getCorrectFontSizeToMatchLabel(label: CCLabelTTF, maxFontSize: Int) -> CGFloat
//    {
//        var fontSize = maxFontSize
//        for fontSize; fontSize > 2; fontSize = fontSize-2
//        {
//            label.fontSize = CGFloat(fontSize)
//            if(label.texture.contentSize().height < label.dimensions.height)
//            {
//                return CGFloat(fontSize)
//            }
//        }
//        return CGFloat(fontSize)
//    }
    
    static func toMainMenu()
    {
        let mainScene = CCBReader.loadAsScene("MainScene")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(mainScene, withTransition: transition)
    }

    static func toSearchSetScene()
    {
        let searchSetScene = CCBReader.loadAsScene("SearchSetScene")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(searchSetScene, withTransition: transition)
    }

    static func toViewDownloadsScene()
    {
        let viewDownloadsScene = CCBReader.loadAsScene("ViewDownloadsScene")
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(viewDownloadsScene, withTransition: transition)
    }
    
    static func toGameplayScene(gameData: GameData)
    {
        let scene = CCScene()
        let flappyScene = CCBReader.load("GameplayFlappy") as! GameplayFlappy
        flappyScene.gameData = gameData
        scene.addChild(flappyScene)
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
}
