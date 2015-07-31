//
//  QuizletResponseModel.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit
import Darwin

class QuizletResponseModel: NSObject
{
    class func parseQuizletFlashcardJSON(data: AnyObject!) -> GameData
    {
        var quizWords = Dictionary<String, String>()
        let json = JSON(data)
        
        for index in 0..<json["terms"].count
        {
            let term = json["terms"][index]["term"].string
            let definition = json["terms"][index]["definition"].string
            quizWords[term!] = definition
        }
        var gameData = GameData()
        gameData.quizWords = quizWords
        gameData.title = json["title"].string
        var tempInt = json["id"].intValue
        gameData.id = "\(tempInt)"
        gameData.createdBy = json["created_by"].string
        return gameData
    }
    
    class func parseQuizletSearchResultJSON(data: AnyObject!) ->[SearchResponse]
    {
        var searchValues: [SearchResponse] = []
        let json = JSON(data)
        
        println(json)
        //println(json["sets"][0])
        
        for index in 0..<json["sets"].count
        {
            if(json["sets"][index]["has_images"].boolValue == false)
            {
                var temp: SearchResponse = SearchResponse()
                var tempInt = json["sets"][index]["id"].intValue
                temp.id = "\(tempInt)"
                temp.title = json["sets"][index]["title"].string
                temp.createdBy = json["sets"][index]["created_by"].string
                var tempTermCount = json["sets"][index]["term_count"].intValue
                temp.termCount = "\(tempTermCount)"
                searchValues.append(temp)
            }
        }

        return searchValues
    }
}
