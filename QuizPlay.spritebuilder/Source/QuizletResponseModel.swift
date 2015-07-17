//
//  QuizletResponseModel.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class QuizletResponseModel: NSObject
{
    var JSONthing : AnyObject!
    {
        didSet
        {
            
        }
    }
    
    class func parseQuizletFlashcardJSON(data: AnyObject!) -> Dictionary<String,String>
    {
        var quizWords = Dictionary<String, String>()
        let json = JSON(data)
        println(json["terms"][0]["definition"])
        
        for index in 0..<json["terms"].count
        {
            println(json["terms"][index]["term"])
//            let definition: String = json["terms"][index]["definition"]
//            quizWords[term] = definition
        }
        println(quizWords)
        return quizWords
    }
}
