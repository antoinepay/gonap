//
//  MKPlace.swift
//  Gonap
//
//  Created by Cristol Luc on 14/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import Foundation
import MapKit

class MKPlace : MKPolygon
{
    var place: Place!;
    var polygon : MKPolygon!;
    var criteriasInPlace : [Int:MKPin]!;
    
    init(place : Place)
    {
        self.polygon = MKPolygon(coordinates: place.boundaries, count: place.boundaries.count);
        self.place  = place;
        self.criteriasInPlace = [Int:MKPin]();
    }
    
    override var pointCount: Int
    {
        return place.boundaries.count;
    }
    
    override func points() -> UnsafeMutablePointer<MKMapPoint> {
        var mapPoints = [MKMapPoint]();
        for p in place.boundaries
        {
            mapPoints.append(MKMapPointForCoordinate(p));
        }
        let pointer: UnsafeMutablePointer = UnsafeMutablePointer(mutating: mapPoints);
        return pointer;
    }
    
    override func intersects(_ mapRect: MKMapRect) -> Bool {
        return polygon.intersects(mapRect);
    }
    
    override var coordinate: CLLocationCoordinate2D
    {
        return polygon.coordinate;
    }
    
    override var interiorPolygons: [MKPolygon]?
    {
        return polygon.interiorPolygons;
    }
    
    override var boundingMapRect: MKMapRect
    {
        return polygon.boundingMapRect;
    }
    
}
