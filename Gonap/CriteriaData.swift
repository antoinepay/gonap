//
//  CriteriaData.swift
//  Gonap
//
//  Created by Cristol Luc on 15/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import Foundation

class CriteriaData {
    var id : Int;
    var name : String;
    var codeFA : Int;

    init() {
        self.id = 0;
        self.name = "Default";
        self.codeFA = 0;
    }
    
    init(id : Int, name: String, codeFA : Int) {
        self.id = id;
        self.name = name;
        self.codeFA = codeFA;
    }
}
