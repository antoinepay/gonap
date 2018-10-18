//
//  PlaceDescriptionTableViewCell.swift
//  Gonap
//
//  Created by Antoine Payan on 14/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import MapKit
import Font_Awesome_Swift

class PlaceDescriptionTableViewCell: UITableViewCell, MKMapViewDelegate {

    @IBOutlet weak var feedbacksLabel: UILabel!
    @IBOutlet weak var validatePlace: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceImage: UIImageView!
    @IBOutlet weak var timeImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var place : Place!;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(zone : Place, feedbacks : [Feedback])
    {
        self.place=zone;
        feedbacksLabel.text=""
        feedbacksLabel.numberOfLines = 0;
        for f in feedbacks
        {
            feedbacksLabel.text?.append(f.name+"\n")
        }
        self.validatePlace.backgroundColor=UIColor(hexString: Colors.green)
        self.validatePlace.tintColor=UIColor.white;
        self.distanceLabel.text="100 m";
        self.distanceImage.image = UIImage(bgIcon: FAType.FALocationArrow, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FALocationArrow, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 25, height: 25));
        self.timeLabel.text = String(Int(zone.travelTime)) + " minutes";
        self.timeImage.image = UIImage(bgIcon: FAType.FAClockO, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FAClockO, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 25, height: 25));

        self.validatePlace.addTarget(self, action: #selector(self.goToMapView), for: .touchUpInside);

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func goToMapView()
    {
        let defaults = UserDefaults.standard;
        if let data = defaults.object(forKey: "places") as? Data {
            var places = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Place];
            var found = false;
            for p in places
            {
                if p.id == self.place.id
                {
                    found = true;
                }
            }
            if(!found)
            {
                places.append(self.place);
                defaults.set(NSKeyedArchiver.archivedData(withRootObject: places), forKey: "places");
            }
        }
        else
        {
            var places = [Place]();
            places.append(self.place);
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: places), forKey: "places");
        }
        defaults.synchronize();
        self.parentViewController?.performSegue(withIdentifier: "placeMapViewSegue", sender: self.parentViewController);
    }
}
