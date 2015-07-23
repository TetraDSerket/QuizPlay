//
//  SearchSetScene.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class SearchSetScene: CCNode, CCTableViewDataSource
{
    weak var searchTextField: CCTextField!
    weak var tableNode: CCNode!
    weak var noSearchResultsLabel: CCLabelTTF!
    var tableView: CCTableView!
    var searchResults: [SearchResponse] = []
    var quizWords = Dictionary<String, String>()
    
    func searchQuizlet()
    {
        let searchString = searchTextField.string
        WebHelper.getQuizletSearchValues(searchValue: searchString, resolve: dealWithSearchResponseResults)
    }
    
    func dealWithSearchResponseResults(searchValues: [SearchResponse])
    {
        searchResults = searchValues
        tableView.reloadData()
        if(searchValues.count == 0)
        {
            noSearchResultsLabel.visible = true
        }
        else
        {
            noSearchResultsLabel.visible = false
        }
    }
    
    func didLoadFromCCB()
    {
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
    }
    
    func tableView(tableView: CCTableView, nodeForRowAtIndex index: UInt) -> CCTableViewCell
    {
        var tableViewCell: CCTableViewCell = CCTableViewCell()
        
        //red: colorFactor, green: 1.0 - colorFactor, blue: 0.2+0.5*colorFactor
        let widthx: Float = Float(CCDirector.sharedDirector().designSize.width) - 20
        let colorFactor: Float = (Float(index) / Float(searchResults.count))
        var colorNode = CCNodeColor(color: CCColor(red: 0.8 - colorFactor, green: 0.2+0.5*colorFactor, blue: colorFactor), width: widthx, height: 30)
        colorNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        colorNode.position = CGPoint(x: CCDirector.sharedDirector().designSize.width/2, y: 0)
        tableViewCell.addChild(colorNode)
        
        var tableLabel = CCLabelTTF(string: searchResults[Int(index)].title, fontName: "Helvetica", fontSize: 14)
        tableLabel.position = CGPoint(x: CCDirector.sharedDirector().designSize.width/2, y: 0)
        tableViewCell.addChild(tableLabel)
        
        var tablePlayButton = CCButton()
        tablePlayButton.preferredSize = CGSize(width: 50, height: 40)
        tablePlayButton.setBackgroundSpriteFrame(CCSpriteFrame(imageNamed: "images/play_button.png"), forState: CCControlState(rawValue: UInt(1))!)
        tablePlayButton.zoomWhenHighlighted = true
        tablePlayButton.setTarget(self, selector: "whenPlayButtonsOnMenuArePressed:")
        tablePlayButton.position = CGPoint(x: CCDirector.sharedDirector().designSize.width*3/4, y: 0)
        tablePlayButton.name = searchResults[Int(index)].id
        tableViewCell.addChild(tablePlayButton)
        
        return tableViewCell
    }
    
    func whenPlayButtonsOnMenuArePressed(button: CCButton!)
    {
        WebHelper.getQuizletFlashcardData(setNumber: button.name,resolve: dealWithQuizWordsLoaded)
    }
    
    func dealWithQuizWordsLoaded(quizWords: Dictionary<String, String>) -> Void
    {
        println(quizWords)
        self.quizWords = quizWords
        let scene = CCScene()
        let flappyScene = CCBReader.load("GameplayFlappy") as! GameplayFlappy
        flappyScene.quizWords = quizWords
        scene.addChild(flappyScene)
        let transition = CCTransition(fadeWithDuration: 0.8)
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }
    
    func tableViewNumberOfRows(tableView: CCTableView) -> UInt
    {
        return UInt(searchResults.count)
    }
    
    func tableView(tableView: CCTableView, heightForRowAtIndex index: UInt) -> Float
    {
        return 40.0
    }
}

struct GameData
{
    var quizWords = Dictionary<String, String>()
    var name: String!
    var id: String!
    var createdBy: String!
}

struct SearchResponse
{
    var id: String!
    var title: String!
    var createdBy: String!
}
