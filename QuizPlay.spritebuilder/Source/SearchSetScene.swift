//
//  SearchSetScene.swift
//  QuizPlay
//
//  Created by Varsha Ramakrishnan on 7/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class SearchSetScene: CCNode
{
    weak var searchTextField: CCTextField!
    
    func searchQuizlet()
    {
        let searchString = searchTextField.string
        println(searchString)
    }
   
}
