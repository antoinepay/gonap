//
//  Place.swift
//  Gonap
//
//  Created by Cristol Luc on 12/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import Foundation
import MapKit

class Place : NSObject, NSCoding
{
    var id : Int;
    var name : String;
    var borderColor : String;
    var backgroundColor : String;
    var boundaries : [CLLocationCoordinate2D];
    var travelTime : Double = 0;
    var rate : Double = 0;
    var travelDistance = 0;
    var feedbacks = [Feedback]();
    
    override init() {
        self.id = -1;
        self.name = "Empty"
        self.borderColor = "#000000"
        self.backgroundColor = "#FFFFFF";
        self.boundaries = [];
    }
    
    init(id : Int, name : String, borderColor : String, backgroundColor : String, boundaries: [CLLocationCoordinate2D]) {
        self.id = id;
        self.name = name;
        self.borderColor = borderColor;
        self.backgroundColor = backgroundColor;
        self.boundaries = boundaries;
    }
    //MARK: - NSCoding -
    required init(coder aDecoder: NSCoder) {
        id = Int(aDecoder.decodeCInt(forKey: "id"));
        name = aDecoder.decodeObject(forKey: "name") as! String;
        borderColor = aDecoder.decodeObject(forKey: "borderColor") as! String;
        backgroundColor = aDecoder.decodeObject(forKey: "backgroundColor") as! String;
        
        /*let boundariesDouble = aDecoder.decodeObject(forKey : "boundaries") as! [CodingLocation];
        boundaries = [CLLocationCoordinate2D]();
        for b in boundariesDouble
        {
            boundaries.append(CLLocationCoordinate2D(latitude: b.latitude, longitude: b.longitude));
        }*/
        let count = aDecoder.decodeCInt(forKey: "count");
        boundaries=[CLLocationCoordinate2D]();
        var locations = [Double]();
        for i in 0...(2*(count)-1)
        {
            if let loc = aDecoder.decodeObject() as? Double
            {
                locations.append(loc);
            }
        }
        var latitude = 0.0;
        var longitude = 0.0;
        for i in 0...locations.count-1
        {
            if (i%2 == 0)
            {
                latitude=locations[i];
            }
            else
            {
                longitude=locations[i];
                boundaries.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude));
            }
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encodeCInt(Int32.init(id), forKey: "id");
        aCoder.encode(name, forKey: "name");
        aCoder.encode(borderColor, forKey:"borderColor");
        aCoder.encode(backgroundColor, forKey : "backgroundColor");
        aCoder.encodeCInt(Int32.init(boundaries.count), forKey: "count");
        /*var boundariesDouble = [CodingLocation]();
        for b in boundaries
        {
            boundariesDouble.append(CodingLocation(latitude: b.latitude, longitude: b.longitude));
        }*/
        for b in boundaries
        {
            aCoder.encode(b.latitude);
            aCoder.encode(b.longitude);
        }
        //aCoder.encode(boundariesDouble, forKey: "boundaries");
    }

}

    
class CodingLocation: NSObject, NSCoding
{
        let latitude: Double
        let longitude: Double
    
        override init()
        {
            self.latitude=0;
            self.longitude=0;
        }
        init(latitude : Double, longitude : Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
        
        required init?(coder aDecoder: NSCoder) {
            self.latitude = aDecoder.decodeObject(forKey: "latitude") as! Double
            self.longitude = aDecoder.decodeObject(forKey: "longitude") as! Double
        }
        
        func encode(with aCoder: NSCoder) {
            aCoder.encode(latitude, forKey: "latitude")
            aCoder.encode(longitude, forKey: "longitude")
        }
}


