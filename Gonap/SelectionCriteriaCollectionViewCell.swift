//
//  SelectionCriteriaCollectionViewCell.swift
//  Gonap
//
//  Created by Antoine Payan on 20/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class SelectionCriteriaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var criteriaImage: UIImageView!
    @IBOutlet weak var criteriaLabel: UILabel!
    
    var criteria : Criteria!;
    func configure(criteria : Criteria)
    {
        criteriaImage.setFAIconWithName(icon: FAType(rawValue : criteria.codeFA)!, textColor: UIColor(hexString : criteria.frontColor), backgroundColor: UIColor.white, size: CGSize(width: 50, height: 50));
        self.criteria=criteria;
        criteriaLabel.text=criteria.name;
        criteriaLabel.textColor=UIColor(hexString: criteria.frontColor);
        self.criteriaImage.isUserInteractionEnabled=true;
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 50,y: 30), radius: CGFloat(28), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.clear.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor(hexString : criteria.frontColor).cgColor;
        //you can change the line width
        shapeLayer.lineWidth = 3.0
        
        contentView.layer.addSublayer(shapeLayer)
        
    }

    
}
