//
//  ViewDownloadsScene.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class ViewDownloadsScene: CCNode, CCTableViewDataSource
{
    weak var tableNode: CCNode!
    weak var noSearchResultsLabel: CCLabelTTF!
    weak var cellColorNode: CCNodeColor!
    weak var cellTitleLabel: CCLabelTTF!
    weak var cellCreatorLabel: CCLabelTTF!
    weak var cellPlayButton: CCButton!
    weak var loadingScreen: CCNode!
    var tableView: CCTableView!
    var searchResults: [SearchResponse] = []
    var quizWords = Dictionary<String, String>()
    
    weak var stencilNode: CCNode!
    weak var clippingNode: CCClippingNode!
    
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
        
        let tableCellNode = CCBReader.load("DownloadCellNode", owner: self)
        tableCellNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tableCellNode.position = CGPoint(x: CCDirector.sharedDirector().designSize.width/2, y: 0)
        
        //cellColorNode.color = CCColor(red: 0.8 - colorFactor, green: 0.2+0.5*colorFactor, blue: colorFactor)
        let colorFactor: Float = (Float(index) / Float(searchResults.count))
        cellColorNode.color = CCColor(red: 0.6*colorFactor+0.1, green: 0.6*colorFactor+0.1, blue: 0.8)
        
//        cellTitleLabel.string = searchResults[Int(index)].title
//        cellCreatorLabel.string = searchResults[Int(index)].createdBy
        
//        cellPlayButton.name = searchResults[Int(index)].id
        cellPlayButton.setTarget(self, selector: "playButtonPressed:")
        
        tableViewCell.addChild(tableCellNode)
        return tableViewCell
    }
    
    func playButtonPressed(button: CCButton!)
    {
        //WebHelper.getQuizletFlashcardData(setNumber: button.name,resolve: dealWithQuizWordsLoaded)
    }
    
    func tableViewNumberOfRows(tableView: CCTableView) -> UInt
    {
        return UInt(searchResults.count)
    }
    
    func tableView(tableView: CCTableView, heightForRowAtIndex index: UInt) -> Float
    {
        return 80.0
    }
}
