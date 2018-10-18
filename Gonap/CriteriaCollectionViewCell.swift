//
//  CriteriaCollectionViewCell.swift
//  Gonap
//
//  Created by Antoine Payan on 11/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class CriteriaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var iconLabel: UILabel!
    
    var criteria : Criteria!;
    var selectionValue : Int = 0;
    var badgeView : UIView!;
    var shapeLayer = CAShapeLayer();
    
    func addOneValue()
    {
        icon.setFAIconWithName(icon: FAType(rawValue : criteria.codeFA)!, textColor: UIColor(hexString : criteria.frontColor), backgroundColor: UIColor.white, size: CGSize(width: 40, height: 40));
        icon.alpha=CGFloat(0.3+Double(selectionValue)*7/30)
        iconLabel.textColor=UIColor(hexString: criteria.frontColor);
        if (selectionValue != 0)
        {
            self.badgeView.removeFromSuperview();
        }
        selectionValue+=1;
        shapeLayer.strokeColor=UIColor(hexString: criteria.frontColor).cgColor;
        self.badgeView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20));
        self.badgeView.layer.cornerRadius=10.0;
        self.badgeView.backgroundColor=UIColor.red;
        let value = UILabel(frame: CGRect(x: 4, y: 0, width: 20, height: 20));
        value.text=String(selectionValue);
        value.textColor=UIColor.white;
        self.badgeView.addSubview(value);
        self.contentView.addSubview(badgeView);
    }
    
    func resetValue()
    {
        icon.setFAIconWithName(icon: FAType(rawValue : criteria.codeFA)!, textColor: UIColor.lightGray, backgroundColor: UIColor.white, size: CGSize(width: 40, height: 40));
        iconLabel.textColor=UIColor.black;
        selectionValue=0;
        shapeLayer.strokeColor = UIColor.lightGray.cgColor;
        self.badgeView.removeFromSuperview();
    }
    
    func configure(criteria : Criteria, count : Int)
    {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 50 ,y: 33), radius: CGFloat(28), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.clear.cgColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.lightGray.cgColor;
        //you can change the line width
        shapeLayer.lineWidth = 3.0
        
        
        if(self.badgeView != nil)
        {
            self.badgeView.removeFromSuperview();
        }
        if(count>0)
        {
            icon.setFAIconWithName(icon: FAType(rawValue : criteria.codeFA)!, textColor: UIColor(hexString : criteria.frontColor), backgroundColor: UIColor.white, size: CGSize(width: 40, height: 40));
            icon.alpha=CGFloat(0.3+Double(selectionValue)*7/30)
            iconLabel.textColor=UIColor(hexString: criteria.frontColor);
            self.badgeView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20));
            self.badgeView.layer.cornerRadius=10.0;
            self.badgeView.backgroundColor=UIColor.red;
            let value = UILabel(frame: CGRect(x: 4, y: 0, width: 20, height: 20));
            value.text=String(count);
            self.selectionValue=count;
            value.textColor=UIColor.white;
            self.badgeView.addSubview(value);
            self.contentView.addSubview(badgeView);
            shapeLayer.strokeColor = UIColor(hexString: criteria.frontColor).cgColor;
        }
        else
        {
            self.selectionValue=0;
            icon.setFAIconWithName(icon: FAType(rawValue : criteria.codeFA)!, textColor: UIColor.lightGray, backgroundColor: UIColor.white, size: CGSize(width: 40, height: 40));
            iconLabel.text=criteria.name;
            iconLabel.textColor=UIColor.black;
        }
        contentView.layer.addSublayer(shapeLayer)
        self.criteria=criteria;
        self.icon.isUserInteractionEnabled=false;
        
    }
}
