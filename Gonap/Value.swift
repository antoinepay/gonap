//
//  Value.swift
//  Gonap
//
//  Created by Antoine Payan on 03/05/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import Foundation

class Value
{
    var placeId : Int;
    var criteriaName : String;
    var rating : Double;
    
    init(place : Int, criteria : String, rating : Double)
    {
        self.placeId=place;
        self.criteriaName=criteria;
        self.rating=rating;
    }
}
