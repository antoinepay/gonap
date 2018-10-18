//
//  PlacesCriteriaViewController.swift
//  Gonap
//
//  Created by Antoine Payan on 12/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import MapKit
import Font_Awesome_Swift

class PlacesCriteriaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var previouslySelectedHeaderIndex: Int?
    var selectedHeaderIndex: Int?
    var selectedItemIndex: Int?
    var selectedPlace : Place!;
    
    var places : [Place] = [];
    var values : [Value] = [];
    var valuesSelected : [Value] = [];
    
    var cells: SwiftyAccordionCells!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cells = SwiftyAccordionCells()
        self.setup()
        self.tableView.estimatedRowHeight = 45
        self.tableView.rowHeight = UITableViewAutomaticDimension
        //self.tableView.allowsMultipleSelection = true
        self.tableView.delegate=self;
        self.tableView.dataSource=self;
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setup() {
        /*var boundaries = [CLLocationCoordinate2D]();
        boundaries.append(CLLocationCoordinate2D(latitude: 45.783718, longitude: 4.874306));
        boundaries.append(CLLocationCoordinate2D(latitude : 45.783658,longitude : 4.873934));
        boundaries.append(CLLocationCoordinate2D(latitude : 45.783950,longitude : 4.873769));
        boundaries.append(CLLocationCoordinate2D(latitude : 45.784062,longitude : 4.874091));
        boundaries.append(CLLocationCoordinate2D(latitude : 45.783957,longitude : 4.874309));
        let zoneTest = Place(id: 1, name: "Pelouse", borderColor: "#DCDCDC", backgroundColor: "#00CC00", boundaries: boundaries);
        self.cells.append(SwiftyAccordionCells.HeaderItem(zone : zoneTest))
        self.cells.append(SwiftyAccordionCells.Item(zone : zoneTest))*/
        for p in places
        {
            self.cells.append(SwiftyAccordionCells.HeaderItem(zone: p))
            self.cells.append(SwiftyAccordionCells.Item(zone: p));
        }
        
    }
    
    func calculateDistance(zone : Place) -> Double
    {
        if((UIApplication.shared.delegate as! AppDelegate).locationManager.location?.coordinate != nil)
        {
            let userLocation = (UIApplication.shared.delegate as! AppDelegate).locationManager.location?.coordinate;
            var distance = CLLocationDistanceMax;
            for boundary in zone.boundaries
            {
                let boundaryLocation = CLLocation(latitude: boundary.latitude, longitude: boundary.longitude);
                let d = boundaryLocation.distance(from: CLLocation.init(latitude: (userLocation?.latitude)!, longitude: (userLocation?.longitude)!));
                if d < distance
                {
                    distance = d
                }
            }
            return distance.rounded();
        }
        return -1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.cells.items[(indexPath as NSIndexPath).row]
        if item is SwiftyAccordionCells.HeaderItem {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "headerCellPlace") as? PlaceCollapseTableViewCell {
                if(item.zone.feedbacks.count>0)
                {
                    cell.placeName.setFAText(prefixText: "", icon: FAType.FAWarning, postfixText: " "+item.zone.name, size: 20)
                    cell.placeName.setFAColor(color: UIColor.orange);
                }
                else
                {
                    cell.placeName.text = item.zone.name
                    cell.placeName.font = UIFont.systemFont(ofSize: 13.0);
                }
                
                cell.configure(rating: (item.zone.rate)/2)
                return cell
            }
        }
        else
        {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cellPlace") {
                let cellDesc = cell as! PlaceDescriptionTableViewCell
                cellDesc.configure(zone: item.zone,feedbacks:  item.zone.feedbacks);
                var distance = 0;
                if item.zone.travelDistance != 0
                {
                    distance = item.zone.travelDistance;
                }
                else
                {
                    distance = Int(calculateDistance(zone: item.zone));
                }
                
                if(distance != -1)
                {
                    cellDesc.distanceLabel.text=String(distance)+" m";
                }
                else
                {
                    cellDesc.distanceLabel.text="Non disponible";
                }
                return cellDesc;
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.cells.items[(indexPath as NSIndexPath).row]
        
        if item is SwiftyAccordionCells.HeaderItem {
            return 80
        }
        else if (item.isHidden) {
            return 0
        }
        else
        {
            return 150;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.cells.items[(indexPath as NSIndexPath).row]
        self.selectedPlace = (item as! SwiftyAccordionCells.HeaderItem).zone
        for v in values
        {
            if v.placeId==self.selectedPlace.id
            {
                self.valuesSelected.append(v);
            }
        }
        if item is SwiftyAccordionCells.HeaderItem {
            if self.selectedHeaderIndex == nil {
                self.selectedHeaderIndex = (indexPath as NSIndexPath).row
            } else {
                self.previouslySelectedHeaderIndex = self.selectedHeaderIndex
                self.selectedHeaderIndex = (indexPath as NSIndexPath).row
            }
            
            if let previouslySelectedHeaderIndex = self.previouslySelectedHeaderIndex {
                self.cells.collapse(previouslySelectedHeaderIndex)
            }
            
            if self.previouslySelectedHeaderIndex != self.selectedHeaderIndex {
                self.previouslySelectedHeaderIndex = self.selectedHeaderIndex
                self.cells.expand(self.selectedHeaderIndex!)
            } else {
                self.selectedHeaderIndex = nil
                self.previouslySelectedHeaderIndex = nil
            }
            
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
        } else {
            /*if (indexPath as NSIndexPath).row != self.selectedItemIndex {
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                
                if let selectedItemIndex = self.selectedItemIndex {
                    let previousCell = self.tableView.cellForRow(at: IndexPath(row: selectedItemIndex, section: 0))
                    previousCell?.accessoryType = UITableViewCellAccessoryType.none
                    cells.items[selectedItemIndex].isChecked = false
                }
                
                self.selectedItemIndex = (indexPath as NSIndexPath).row
                cells.items[self.selectedItemIndex!].isChecked = true
            }*/
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "placeMapViewSegue"
        {
            let vc = segue.destination as! PlaceDisplayViewController
            vc.place=selectedPlace;
            vc.values=valuesSelected;
        }
    }

}
