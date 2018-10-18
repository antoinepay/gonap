//
//  GlobalMapCriteriaCollectionViewCell.swift
//  Gonap
//
//  Created by Cristol Luc on 12/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class ResultMapCriteriaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var iconSwitch: UISwitch!
    @IBOutlet weak var iconLabel: UILabel!
    
    @IBAction func switchAction(_ sender: UISwitch) {
        self.selectedCriteria = sender.isOn;
        (self.parentViewController as! PlaceDisplayViewController).switchAction(cell: self);
        if(criteria.name == "Zone de détente") {
            (self.parentViewController as! PlaceDisplayViewController).isPlacesSelecred = self.selectedCriteria;
        }
    }
    
    var criteria : Criteria!;
    var selectedCriteria : Bool = false;
    
    func configure(criteria : Criteria)
    {
        self.selectedCriteria = false;
        self.criteria = criteria;
        self.icon.isUserInteractionEnabled = false;
        self.icon.setFAIconWithName(icon: FAType(rawValue : criteria.codeFA)!, textColor: UIColor.black, backgroundColor: UIColor.clear, size: CGSize(width: 48, height: 48));
        self.iconLabel.text = criteria.name;
    }
    
    func setSelected(criteria : Criteria)
    {
        self.selectedCriteria = true;
        self.iconSwitch.setOn(true, animated: true);
    }
    
    func setUnselected()
    {
        self.selectedCriteria = false;
        self.iconSwitch.setOn(true, animated: true);
    }
    
}
