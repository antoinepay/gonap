//
//  PlaceCollapseTableViewCell.swift
//  Gonap
//
//  Created by Antoine Payan on 01/05/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit

class PlaceCollapseTableViewCell: UITableViewCell {

    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var rating: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure (rating : Double)
    {
        self.rating.rating=rating;
    }

}
