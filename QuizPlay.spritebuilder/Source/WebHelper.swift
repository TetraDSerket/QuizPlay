//
//  WebHelper.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

//template: Alamofire.request(.GET, "https://api.quizlet.com/2.0/sets/SETNUMBERHERE?client_id=d8cM6gPAhD&whitespace=1")

import UIKit
import Alamofire

class WebHelper: NSObject
{
    static var gameData = GameData()
    static var searchValues: [SearchResponse]!
    
    class func getQuizletFlashcardData(#setNumber: String, resolve: (gameData: GameData) -> Void)
    {
        Alamofire.request(.GET, "https://api.quizlet.com/2.0/sets/\(setNumber)?client_id=d8cM6gPAhD&whitespace=1")
            .responseJSON
        { request, response, data, error in
            self.gameData = QuizletResponseModel.parseQuizletFlashcardJSON(data)
            resolve(gameData: self.gameData)
        }
    }
    
    class func getQuizletSearchValues(#searchValue: String, resolve: (searchResults: [SearchResponse]) -> Void)
    {
        let encodedSearchValue = searchValue.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        println(encodedSearchValue!)
        Alamofire.request(.GET, "https://api.quizlet.com/2.0/search/sets?client_id=d8cM6gPAhD&whitespace=1&q=\(encodedSearchValue!)")
            .responseJSON
        { request, response, data, error in
            self.searchValues = QuizletResponseModel.parseQuizletSearchResultJSON(data)
            resolve(searchResults: self.searchValues)
        }
        
    }
}
