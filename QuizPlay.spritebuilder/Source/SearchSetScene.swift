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
//        if(searchValues.count == 0)
//        {
//            noSearchResultsLabel.visible = true
//        }
//        else
//        {
//            noSearchResultsLabel.visible = false
//        }
    }
    
    func didLoadFromCCB()
    {
        userInteractionEnabled = true
        tableView = CCTableView()
        tableView.dataSource = self
        tableView.block =
        {(sender: AnyObject!) in
            NSLog("row selected: %i", Int(self.tableView.selectedRow))
            println("YO YO YOU SELECTED A ROW")
        }
        var ableView = CCNodeColor(color: CCColor(red: 0.5, green: 0.5, blue: 0.5))
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
        var tableLabel = CCLabelTTF(string: searchResults[Int(index)].title, fontName: "Helvetica", fontSize: 14)
        //tableLabel.positionType = tableNode.positionType
        tableLabel.position = CGPoint(x: CCDirector.sharedDirector().designSize.width/2, y: 0)
        tableViewCell.addChild(tableLabel)
        return tableViewCell
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
