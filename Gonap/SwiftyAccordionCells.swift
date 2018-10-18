//
//  SwiftyAccordionCells.swift
//  SwiftyAccordionCells
//
//  Created by Fischer, Justin on 9/24/15.
//  Copyright © 2015 Justin M Fischer. All rights reserved.
//

import Foundation

class SwiftyAccordionCells {
    fileprivate (set) var items = [Item]()
    
    class Item {
        var isHidden: Bool
        var zone : Place;
        
        init(_ hidden: Bool = true, zone : Place) {
            self.isHidden = hidden
            self.zone = zone
        }
    }
    
    class HeaderItem: Item {
        init (zone : Place) {
            super.init(false, zone : zone)
        }
    }
    
    func append(_ item: Item) {
        self.items.append(item)
    }
    
    func removeAll() {
        self.items.removeAll()
    }
    
    func expand(_ headerIndex: Int) {
        self.toogleVisible(headerIndex, isHidden: false)
    }
    
    func collapse(_ headerIndex: Int) {
        self.toogleVisible(headerIndex, isHidden: true)
    }
    
    private func toogleVisible(_ headerIndex: Int, isHidden: Bool) {
        var headerIndex = headerIndex
        headerIndex += 1
        
        while headerIndex < self.items.count && !(self.items[headerIndex] is HeaderItem) {
            self.items[headerIndex].isHidden = isHidden
            
            headerIndex += 1
        }
    }
}
