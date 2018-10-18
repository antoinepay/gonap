//
//  MKPin.swift
//  Gonap
//
//  Created by Cristol Luc on 14/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import Foundation
import MapKit

class MKPin : MKPointAnnotation
{
    var criteria: Criteria;
    
    init(criteria: Criteria){
        self.criteria = criteria;
        super.init();
    }
}
