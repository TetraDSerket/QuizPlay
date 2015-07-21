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
    static var quizWords = Dictionary<String, String>()
    
    class func getQuizletFlashcardData(resolve: (quizWords: Dictionary<String, String>) -> Void)
    {
        //Homestuck: 18853693
        //Indonesian: 1716014
        
        Alamofire.request(.GET, "https://api.quizlet.com/2.0/sets/17163034?client_id=d8cM6gPAhD&whitespace=1")
            .responseJSON
        { request, response, data, error in
            self.quizWords = QuizletResponseModel.parseQuizletFlashcardJSON(data)
            resolve(quizWords: self.quizWords)
        }
        //println("WebHelper \(quizWords.count)")
    }
}
