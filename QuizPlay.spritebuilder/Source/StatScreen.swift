//
//  StatScreen.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 8/4/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

struct WordStat
{
    var word: String
    var definition: String
    var correctResponses: Int
    var wrongResponses: Int
}

class StatScreen: CCNode, CCTableViewDataSource
{
    weak var tableNode: CCNode!
    weak var noStatsLabel: CCLabelTTF!
    weak var loadingScreen: CCNode!
    var tableView: CCTableView!
    
    var defPopup: CCNode!
    weak var definitionLabel: CCLabelTTF!
    
    //keys are the words, each is connected to a wordstat object that tells about it
    var statsArray: [WordStat]!
    var gameData: GameData!
    var nameOfGame: String!
    
    weak var stencilNode: CCNode!
    weak var clippingNode: CCClippingNode!
    
    weak var cellColorNode: CCNodeColor!
    weak var correctResponsesLabel: CCLabelTTF!
    weak var wrongResponsesLabel: CCLabelTTF!
    weak var cellWordLabel: CCLabelTTF!
    weak var showDefinitionButton: CCButton!
       
    override func onEnter()
    {
        userInteractionEnabled = true
        if(statsArray.count == 0)
        {
            noStatsLabel.visible = true
        }
        tableView = CCTableView()
        tableView.dataSource = self
        tableView.block =
        { (tableView) in
                NSLog("Selected cell at index: %i", Int(tableView.selectedRow))
        }
        tableView.contentSize = self.contentSize
        tableView.contentSizeType = self.contentSizeType
        tableNode.addChild(tableView)
        
        defPopup = CCBReader.load("DefinitionPopup", owner: self)
        defPopup.positionType = CCPositionType(xUnit: .Normalized, yUnit: .Normalized, corner: .BottomLeft)
        defPopup.position = CGPoint(x: 0.5, y: 0.5)
        defPopup.visible = false
        self.addChild(defPopup)
        
        clippingNode.stencil = stencilNode
        clippingNode.alphaThreshold = 0.0
    }
    
    func tableView(tableView: CCTableView, nodeForRowAtIndex index: UInt) -> CCTableViewCell
    {
        var tableViewCell: CCTableViewCell = CCTableViewCell()
        
        let tableCellNode = CCBReader.load("StatCellNode", owner: self)
        tableCellNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tableCellNode.position = CGPoint(x: CCDirector.sharedDirector().designSize.width/2, y: 0)
        
        let thisOrThat = Float(index%2) / 8
//        println(thisOrThat)
        cellColorNode.color = CCColor(red: thisOrThat, green: thisOrThat, blue: thisOrThat)
        
        correctResponsesLabel.string = "\(statsArray[Int(index)].correctResponses)"
        wrongResponsesLabel.string = "\(statsArray[Int(index)].wrongResponses)"
        cellWordLabel.string = "\(statsArray[Int(index)].word)"
        cellWordLabel.fontSize = MiscMethods.getCorrectFontSizeToMatchLabel(cellWordLabel, maxFontSize: 40)
        
        showDefinitionButton.name = "\(statsArray[Int(index)].definition)"
        showDefinitionButton.setTarget(self, selector: "defButtonPressed:")
        
        tableViewCell.addChild(tableCellNode)
        return tableViewCell
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!)
    {
        defPopup.visible = false
    }
    
    func defButtonPressed(button: CCButton!)
    {
        defPopup.visible = true
        definitionLabel.string = button.name
        definitionLabel.fontSize = MiscMethods.getCorrectFontSizeToMatchLabel(definitionLabel, maxFontSize: 50)
    }
    
//    func definitionGoAwayButton()
//    {
//        defPopup.visible = false
//    }
    
    func replayGame()
    {
        MiscMethods.toGameplayScene(gameData, nameOfGame: nameOfGame)
    }
    
    func toSearchSetScene()
    {
        MiscMethods.toSearchSetScene()
    }
    
    func tableViewNumberOfRows(tableView: CCTableView) -> UInt
    {
        return UInt(statsArray.count)
    }
    
    func tableView(tableView: CCTableView, heightForRowAtIndex index: UInt) -> Float
    {
        return 60.0
    }
}
