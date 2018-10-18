//
//  Feedback.swift
//  Gonap
//
//  Created by Antoine Payan on 03/05/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import Foundation

class Feedback {
    var id : Int;
    var name : String;
    var duration : Int;
    
    init(id: Int,name : String, duration : Int) {
        self.id = id;
        self.name=name;
        self.duration=duration;
    }
}
