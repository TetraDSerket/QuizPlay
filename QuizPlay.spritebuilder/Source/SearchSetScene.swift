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
        //var ableView = CCNodeColor(color: CCColor(red: 0.5, green: 0.5, blue: 0.5))
//        ableView.positionType = tableNode.positionType
//        ableView.position = tableNode.position
//        ableView.anchorPoint = tableNode.anchorPoint
        tableView.contentSize = self.contentSize
        tableView.contentSizeType = self.contentSizeType
        tableNode.addChild(tableView)
    }
    
    func tableView(tableView: CCTableView, nodeForRowAtIndex index: UInt) -> CCTableViewCell
    {
        var tableViewCell: CCTableViewCell = CCTableViewCell()
        tableViewCell.button.enabled = true
        
        //red: colorFactor, green: 1.0 - colorFactor, blue: 0.2+0.5*colorFactor
        let widthx: Float = Float(CCDirector.sharedDirector().designSize.width) - 20
        let colorFactor: Float = (Float(index) / Float(searchResults.count))
        var colorNode = CCNodeColor(color: CCColor(red: 0.8 - colorFactor, green: 0.2+0.5*colorFactor, blue: colorFactor), width: widthx, height: 30)
        colorNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        colorNode.position = CGPoint(x: CCDirector.sharedDirector().designSize.width/2, y: 0)
        tableViewCell.addChild(colorNode)
        
//        var tableLabel = CCLabelTTF(string: searchResults[Int(index)].title, fontName: "Helvetica", fontSize: 14)
//        tableLabel.position = CGPoint(x: CCDirector.sharedDirector().designSize.width/2, y: 0)
//        tableViewCell.addChild(tableLabel)
        
        var tableButton = CCButton(title: searchResults[Int(index)].title)
        tableButton.setTarget(self, selector: "whenButtonsOnMenuArePressed:")
        tableButton.position = CGPoint(x: CCDirector.sharedDirector().designSize.width/2, y: 0)
        tableButton.name = searchResults[Int(index)].id
        tableViewCell.addChild(tableButton)
        
        return tableViewCell
    }
    
    func whenButtonsOnMenuArePressed(button: CCButton!)
    {
        println("CLICKITY CLICK \(button.name)")
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

struct SearchResponse
{
    var id: String!
    var title: String!
    var createdBy: String!
}
