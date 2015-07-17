//
//  WebHelper.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/16/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit
import Alamofire

class WebHelper: NSObject
{
    class func getQuizletData()
    {
        Alamofire.request(.GET, "https://api.quizlet.com/2.0/sets/415?client_id=d8cM6gPAhD&whitespace=1")
            .responseJSON
        { request, response, data, error in
            QuizletResponseModel.parseQuizletFlashcardJSON(data)
            
//            if let appName = json["feed"]["entry"][0]["im:name"]["label"].string
//            {
//                println("SwiftyJSON: \(appName)")
//            }
            
//            println("REQUEST \(request)")
//            println("RESPONSE \(response)")
//            println("DATA \(data)")
//            println("ERROR \(error)")
        }
        
    }
}
