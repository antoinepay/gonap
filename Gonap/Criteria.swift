//
//  Criteria.swift
//  Gonap
//
//  Created by Antoine Payan on 11/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import Foundation

class Criteria : Hashable
{
    var id : Int;
    var name : String;
    var category : String;
    var backgroundColor : String;
    var frontColor : String;
    var codeFA : Int;
    var hashValue: Int { return ObjectIdentifier(self).hashValue }
    
    init() {
        self.id = -1;
        self.name = "Empty"
        self.category = "None"
        self.backgroundColor = "#FFFFFF";
        self.frontColor = "#000000";
        self.codeFA=1;
    }
    
    init(id : Int, name : String, category : String, backgroundColor : String, frontColor : String, codeFA : Int) {
        self.id = id;
        self.name = name;
        self.category = category;
        self.backgroundColor = backgroundColor;
        self.frontColor = frontColor;
        self.codeFA = codeFA;
    }

    static func ==(lhs: Criteria, rhs: Criteria) -> Bool {
        return lhs === rhs
    }
}
