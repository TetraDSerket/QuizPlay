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
    weak var cellColorNode: CCNodeColor!
    weak var cellTitleLabel: CCLabelTTF!
    weak var cellCreatorLabel: CCLabelTTF!
    weak var cellPlayButton: CCButton!
    weak var cellDownloadButton: CCButton!
    weak var loadingScreen: CCNode!
    var tableView: CCTableView!
    var searchResults: [SearchResponse] = []
    var quizWords = Dictionary<String, String>()
    
    weak var stencilNode: CCNode!
    weak var clippingNode: CCClippingNode!
    
    func searchQuizlet()
    {
        loadingScreen.visible = true
        let searchString = searchTextField.string
        WebHelper.getQuizletSearchValues(searchValue: searchString, resolve: dealWithSearchResponseResults)
    }
    
    func dealWithSearchResponseResults(searchValues: [SearchResponse])
    {
        searchResults = searchValues
        loadingScreen.visible = false
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
        
        clippingNode.stencil = stencilNode
        clippingNode.alphaThreshold = 0.0
    }
    
    func tableView(tableView: CCTableView, nodeForRowAtIndex index: UInt) -> CCTableViewCell
    {
        var tableViewCell: CCTableViewCell = CCTableViewCell()
        
        let tableCellNode = CCBReader.load("SearchCellNode", owner: self)
        tableCellNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tableCellNode.position = CGPoint(x: CCDirector.sharedDirector().designSize.width/2, y: 0)
        
        //cellColorNode.color = CCColor(red: 0.8 - colorFactor, green: 0.2+0.5*colorFactor, blue: colorFactor)
        let colorFactor: Float = (Float(index) / Float(searchResults.count))
        cellColorNode.color = CCColor(red: 0.6*colorFactor+0.1, green: 0.6*colorFactor+0.1, blue: 0.8)
        
        cellTitleLabel.string = searchResults[Int(index)].title
        cellCreatorLabel.string = searchResults[Int(index)].createdBy
        
        cellPlayButton.name = searchResults[Int(index)].id
        cellPlayButton.setTarget(self, selector: "buttonPressed:")
        
        cellDownloadButton.name = searchResults[Int(index)].id
        cellDownloadButton.setTarget(self, selector: "downloadButtonPressed:")
        
        tableViewCell.addChild(tableCellNode)
        return tableViewCell
    }
    
    func buttonPressed(button: CCButton!)
    {
        WebHelper.getQuizletFlashcardData(setNumber: button.name,resolve: dealWithQuizWordsLoaded)
    }
    
    func downloadButtonPressed(button: CCButton!)
    {
        WebHelper.getQuizletFlashcardData(setNumber: button.name,resolve: dealWithDownloadWordsLoaded)
    }
    
    func dealWithDownloadWordsLoaded(gameData: GameData) -> Void
    {
        //store Game Data in NSUserdefaults array(downloads) of dictionaries(tempDictionary)
        var downloadsArray = NSUserDefaults.standardUserDefaults().arrayForKey("downloads") as? [Dictionary<String,String>] ?? [Dictionary<String,String>]()
        println(downloadsArray)
        var tempDictionary = gameData.quizWords
        tempDictionary["GDidVarsha"] = gameData.id
        tempDictionary["GDtitleVarsha"] = gameData.title
        tempDictionary["GDcreatorVarsha"] = gameData.createdBy
        println(tempDictionary)
        downloadsArray.append(tempDictionary)
        NSUserDefaults.standardUserDefaults().setObject(downloadsArray, forKey: "downloads")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func clearDownloads()
    {
        var clearArray = [Dictionary<String,String>]()
        NSUserDefaults.standardUserDefaults().setObject(clearArray, forKey: "downloads")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func dealWithQuizWordsLoaded(gameData: GameData) -> Void
    {
        let scene = CCScene()
        let flappyScene = CCBReader.load("GameplayFlappy") as! GameplayFlappy
        flappyScene.gameData = gameData
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
        return 80.0
    }
    
    func toMainMenu()
    {
        
    }
}

struct GameData
{
    var quizWords = Dictionary<String, String>()
    var title: String!
    var id: String!
    var createdBy: String!
}

struct SearchResponse
{
    var id: String!
    var title: String!
    var createdBy: String!
}
