//
//  CategoryCriteriaTableViewCell.swift
//  Gonap
//
//  Created by Antoine Payan on 11/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit

class CategoryCriteriaTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var criteriaCollectionView: UICollectionView!
    var criterias : [Criteria] = [];
    var criteriasSelected : [Criteria:Int] = [:];
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(criterias : [Criteria], selected : [Criteria:Int])
    {
        self.criterias=criterias;
        for c in selected
        {
            criteriasSelected[c.key]=c.value;
        }
        self.criteriaCollectionView.delegate=self;
        self.criteriaCollectionView.dataSource=self;
        self.criteriaCollectionView.reloadData();
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return criterias.count;
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "criteriaCell", for: indexPath) as! CriteriaCollectionViewCell
        
        cell.configure(criteria: criterias[indexPath.row], count : criteriasSelected[criterias[indexPath.row]]!);
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CriteriaCollectionViewCell
        if(cell.selectionValue==3)
        {
            cell.resetValue();
        }
        else
        {
            cell.addOneValue();
        }
        let pvc = self.parentViewController as! CriteriaListViewController;
        pvc.criteriasSelected[cell.criteria]=cell.selectionValue;
        criteriasSelected[cell.criteria]=cell.selectionValue;
        pvc.validateCriteria.isOpaque=true;
        pvc.validateCriteria.isEnabled=false;
        for c in pvc.criteriasSelected
        {
            if c.value>0
            {
                pvc.validateCriteria.isOpaque=false;
                pvc.validateCriteria.isEnabled=true;
            }
        }
    }
    
    

}
