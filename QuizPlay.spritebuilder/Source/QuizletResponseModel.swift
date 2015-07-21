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
    class func parseQuizletFlashcardJSON(data: AnyObject!) -> Dictionary<String,String>
    {
        var quizWords = Dictionary<String, String>()
        let json = JSON(data)
        
        for index in 0..<json["terms"].count
        {
            let term = json["terms"][index]["term"].string
            let definition = json["terms"][index]["definition"].string
            quizWords[term!] = definition
        }
        return quizWords
    }
}
