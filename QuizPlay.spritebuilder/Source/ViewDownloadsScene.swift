//
//  ViewDownloadsScene.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//
/*
var highScore: Int = NSUserDefaults.standardUserDefaults().integerForKey("myHighScore") ?? 0
{
didSet
{
    NSUserDefaults.standardUserDefaults().setInteger(highScore, forKey:"myHighScore")
    NSUserDefaults.standardUserDefaults().synchronize()
}
}
*/

import UIKit
import Mixpanel

class ViewDownloadsScene: CCNode, CCTableViewDataSource
{
    weak var tableNode: CCNode!
    weak var noDownloadsLabel: CCLabelTTF!
    weak var cellColorNode: CCNodeColor!
    weak var cellTitleLabel: CCLabelTTF!
    weak var cellCreatorLabel: CCLabelTTF!
    weak var cellPlayButton: CCButton!
    weak var cellDeleteButton: CCButton!
    weak var loadingScreen: CCNode!
    var tableView: CCTableView!
    
    var downloadsArray: [Dictionary<String, String>]!
    
    weak var stencilNode: CCNode!
    weak var clippingNode: CCClippingNode!
    var mixpanel = Mixpanel.sharedInstance()
    
    func didLoadFromCCB()
    {
        downloadsArray = NSUserDefaults.standardUserDefaults().arrayForKey("downloads") as? [Dictionary<String,String>] ?? [Dictionary<String,String>]()
        if(downloadsArray == [Dictionary<String, String>]())
        {
            noDownloadsLabel.visible = true
        }
        
        userInteractionEnabled = true
        tableView = CCTableView()
        tableView.dataSource = self
        tableView.block =
        { (tableView) in
                NSLog("Selected cell at index: %i", Int(tableView.selectedRow))
        }
        tableView.contentSize = self.contentSize
        tableView.contentSizeType = self.contentSizeType
        tableNode.addChild(tableView)
        
        clippingNode.stencil = stencilNode
        clippingNode.alphaThreshold = 0.0
    }
    
    func tableView(tableView: CCTableView, nodeForRowAtIndex index: UInt) -> CCTableViewCell
    {
        var tableViewCell: CCTableViewCell = CCTableViewCell()
        
        let tableCellNode = CCBReader.load("DownloadCellNode", owner: self)
        tableCellNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tableCellNode.position = CGPoint(x: CCDirector.sharedDirector().designSize.width/2, y: 0)
        
        //cellColorNode.color = CCColor(red: 0.8 - colorFactor, green: 0.2+0.5*colorFactor, blue: colorFactor)    
//        let colorFactor: Float = (Float(index) / Float(downloadsArray.count))
//        cellColorNode.color = CCColor(red: 0.6*colorFactor+0.1, green: 0.6*colorFactor+0.1, blue: 0.8)
        let thisOrThat = Float(index%2) / 10
//        println(thisOrThat)
        cellColorNode.color = CCColor(red: thisOrThat, green: thisOrThat, blue: thisOrThat+0.15)
        
        
        cellTitleLabel.string = downloadsArray[Int(index)]["GDtitleVarsha"]
        cellCreatorLabel.string = downloadsArray[Int(index)]["GDcreatorVarsha"]
        
        cellPlayButton.name = "\(index)"
        cellPlayButton.setTarget(self, selector: "playButtonPressed:")
        
        cellDeleteButton.name = "\(index)"
        cellDeleteButton.setTarget(self, selector: "deleteButtonPressed:")
        
        tableViewCell.addChild(tableCellNode)
        return tableViewCell
    }
    
    func playButtonPressed(button: CCButton!)
    {
        loadingScreen.visible = true
        var quizWordsAndGameInfo = downloadsArray[button.name.toInt()!]
        var gameData: GameData = GameData()
        gameData.title = quizWordsAndGameInfo.removeValueForKey("GDtitleVarsha")
        gameData.id = quizWordsAndGameInfo.removeValueForKey("GDidVarsha")
        gameData.createdBy = quizWordsAndGameInfo.removeValueForKey("GDcreatorVarsha")
        gameData.quizWords = quizWordsAndGameInfo
        
        MiscMethods.toGameplayScene(gameData)
    }
    
    func deleteButtonPressed(button: CCButton!)
    {
        downloadsArray.removeAtIndex(button.name.toInt()!)
        NSUserDefaults.standardUserDefaults().setObject(downloadsArray, forKey: "downloads")
        NSUserDefaults.standardUserDefaults().synchronize()
        tableView.reloadData()
    }
    
    func toSearchSetScene()
    {
        mixpanel.track("To Another Scene", properties: ["To Scene": "Search", "From Scene": "Download"])
        MiscMethods.toSearchSetScene()
    }
    
    func toMainMenu()
    {
        mixpanel.track("To Another Scene", properties: ["To Scene": "Main", "From Scene": "Download"])
        MiscMethods.toMainMenu()
    }
    
    func tableViewNumberOfRows(tableView: CCTableView) -> UInt
    {
        return UInt(downloadsArray.count)
    }
    
    func tableView(tableView: CCTableView, heightForRowAtIndex index: UInt) -> Float
    {
        return 60.0
    }
}
