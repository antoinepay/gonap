//
//  Category.swift
//  Gonap
//
//  Created by Antoine Payan on 14/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import Foundation

class Category {
    var id : Int;
    var name : String;
    var criterias : [Criteria];
    
    init(id : Int, name : String, criterias : [Criteria]) {
        self.id = id;
        self.name=name;
        self.criterias=criterias;
    }
}
