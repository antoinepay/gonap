//
//  PlaceDisplayViewController.swift
//  Gonap
//
//  Created by Antoine Payan on 15/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import MapKit
import Font_Awesome_Swift

class PlaceDisplayViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate, UIGestureRecognizerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var criteriaCollectionView: UICollectionView!
    @IBOutlet weak var dataContainer: UIView!
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var chevronLeftRight: UIButton!
    @IBOutlet weak var chevronUpDown: UIButton!
    
    @IBOutlet weak var mapColorImage: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var address2lLabel: UILabel!
    @IBOutlet weak var address3Label: UILabel!
    @IBOutlet weak var timeTravelImage: UIImageView!
    @IBOutlet weak var timeTravelLabel: UILabel!
    @IBOutlet weak var distanceTravelLabel: UILabel!
    @IBOutlet weak var distanceTravelImage: UIImageView!
    
    @IBOutlet weak var goToButton: UIButton!
    
    var isPlacesSelecred : Bool!;
    var place : Place!;
    var mkPlace : MKPlace!;
    var criterias   : [Criteria]              = [];
    var annotations : [String:[MKAnnotation]] = [:];
    var values : [Value] = [];
    
    @IBOutlet weak var titleMaxRating: UILabel!
    @IBOutlet weak var maxRating: CosmosView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title=place.name;
        self.mapView.delegate                  = self;
        self.criteriaCollectionView.delegate   = self;
        self.criteriaCollectionView.dataSource = self;
        self.criteriaCollectionView.backgroundColor = UIColor.clear;
        
        let zone = MKPlace(place: place);
        self.mapView.add(zone);
        //--- MapView settings
        //
        mapView.setCenter(zone.coordinate, animated: true);
        
        var mapPoint = MKMapPoint();
        let mapSize = MKMapSize(width: 10000, height: 10000);
        mapPoint = MKMapPointForCoordinate(zone.coordinate);
        mapPoint.x-=5000;
        mapPoint.y-=5000;
        let mapRect = MKMapRect.init(origin: mapPoint, size: mapSize);
        mapView.setVisibleMapRect(mapRect, animated: false);
        
        let defaults = UserDefaults.standard;
        if let mapType = defaults.integer(forKey: "mapType") as? Int
        {
            mapView.mapType=MKMapType.init(rawValue: UInt(mapType))!;
        }
        else
        {
            mapView.mapType=MKMapType.init(rawValue: 0)!;
        }
        
        mapView.showsCompass      = true;
        mapView.showsUserLocation = true;
        mapView.showsBuildings    = true;
        mapView.showsScale        = true;
        
        mapView.showsTraffic          = false;
        mapView.showsPointsOfInterest = false;
        
        mapView.isZoomEnabled   = true;
        mapView.isPitchEnabled  = true;
        mapView.isRotateEnabled = true;
        mapView.isScrollEnabled = true;
        // Do any additional setup after loading the view.
        
        self.mkPlace = MKPlace(place: place);
        
        self.chevronLeftRight.setImage(UIImage(bgIcon: FAType.FAChevronCircleRight, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FAChevronCircleRight, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 25, height: 25)), for: UIControlState.normal);
        self.chevronUpDown.setImage(UIImage(bgIcon: FAType.FAChevronDown, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FAChevronDown, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 55, height: 55)), for: UIControlState.normal);
        self.initDataContainer();
        
        self.criteriaCollectionView.reloadData();
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:)));
        recognizer.delegate = self;
        self.mapView.addGestureRecognizer(recognizer);
        
        var max :Double = 0;
        var value : Value!;
        for v in values
        {
            if v.rating>max{
                max=v.rating
                value=v;
            }
        }
        if (value != nil)
        {
            maxRating.rating=value.rating;
            titleMaxRating.text=value.criteriaName;
        }
        else
        {
            titleMaxRating.removeFromSuperview();
            maxRating.removeFromSuperview();
        }
        
        self.goToButton.layer.cornerRadius = 40;
        self.goToButton.setFATitleColor(color: UIColor.white);
        self.goToButton.backgroundColor=UIColor(hexString: Colors.redGL);
        
        //self.displayCriterias(display: true, criteriaName: "Zone de détente");
    }
    
    func initDataContainer() {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: mkPlace.coordinate.latitude, longitude: mkPlace.coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Location name
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                self.addressLabel.text = locationName as String;
            }
            // Street address
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                self.address2lLabel.text = street as String;
            }
            var address3 = "";
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                address3 = city as String;
            }
            // Zip code
            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                address3 += " ";
                address3 += zip as String;
            }
            self.address3Label.text = address3;
        })
        self.mapColorImage.image = UIImage(bgIcon: FAType.FACircle, bgTextColor: UIColor(hexString: place.backgroundColor), bgBackgroundColor: UIColor.clear, topIcon: FAType.FACircle, topTextColor: UIColor(hexString: place.backgroundColor), bgLarge: true, size: CGSize(width: 25, height: 25));
        self.placeNameLabel.text = place.name;
        self.timeTravelLabel.text = String(Int(place.travelTime))+" minutes";
        self.timeTravelImage.image = UIImage(bgIcon: FAType.FAClockO, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FAClockO, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 30, height: 30));
        var distance = 0;
        if place.travelDistance != 0
        {
            distance = place.travelDistance;
        }
        else
        {
            distance = Int(calculateDistance(zone: place));
        }
        if(distance != -1)
        {
            self.distanceTravelLabel.text=String(distance)+" m";
        }
        else
        {
            self.distanceTravelLabel.text="Non disponible";
        }
        self.distanceTravelImage.image = UIImage(bgIcon: FAType.FALocationArrow, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FALocationArrow, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 30, height: 30));
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        let touchPoint = recognizer.location(in: mapView);
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView);
        var array = [CGPoint]();
        for bound in mkPlace.place.boundaries {
            let point = CGPoint(x: bound.latitude, y: bound.longitude);
            array.append(point);
        }
        let coord = CGPoint(x: coordinates.latitude, y: coordinates.longitude);
        if(self.contains(polygon: array, test: coord) && self.isPlacesSelecred) {
            self.chevronUpDown.isHidden = false;
            self.animateChevronUpDown(up : true);
            let center = mkPlace.polygon.coordinate;
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            self.mapView.setRegion(region, animated: true);
        }
        
    }
    
    func contains(polygon: [CGPoint], test: CGPoint) -> Bool {
        if polygon.count <= 2 {
            return false //or if first point = test -> return true
        }
        
        let p = UIBezierPath()
        let firstPoint = polygon[0] as CGPoint
        
        p.move(to: firstPoint)
        
        for index in 1...polygon.count-1 {
            p.addLine(to: polygon[index] as CGPoint)
        }
        
        p.close()
        
        return p.contains(test)
    }
    
    @IBAction func goToPlace(_ sender: UIButton) {
        let alert = UIAlertController(title: "Par quel moyen ?", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Plans", style: .default, handler: { (action: UIAlertAction!) in
            UIApplication.shared.openURL(NSURL(string:"http://maps.apple.com/maps?saddr=\(self.mapView.userLocation.coordinate.latitude),\(self.mapView.userLocation.coordinate.longitude)&daddr=\(self.mkPlace.coordinate.latitude),\(self.mkPlace.coordinate.longitude)")! as URL);
            alert.dismiss(animated: true, completion: nil)
        }));
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
            alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { (action: UIAlertAction!) in
                UIApplication.shared.openURL(NSURL(string:
                    "comgooglemaps://?saddr=&daddr=\(self.mkPlace.coordinate.latitude),\(self.mkPlace.coordinate.longitude)&directionsmode=driving")! as URL)
                alert.dismiss(animated: true, completion: nil)
            }));
        }
        alert.addAction(UIAlertAction(title: "Uber", style: .default, handler: { (action: UIAlertAction!) in
            if(UIApplication.shared.canOpenURL(NSURL(string:"uber://")! as URL)) {
                UIApplication.shared.openURL(NSURL(string:"uber://")! as URL);
            }
            else {
                UIApplication.shared.openURL(NSURL(string:"itms-apps://itunes.apple.com/app/bars/id368677368")! as URL);
            }
            alert.dismiss(animated: true, completion: nil);
        }));
        alert.addAction(UIAlertAction(title: "CityMapper", style: .default, handler: { (action: UIAlertAction!) in
            if(UIApplication.shared.canOpenURL(NSURL(string:"citymapper://")! as URL)) {
                UIApplication.shared.openURL(NSURL(string:"citymapper://directions?startcoord=\(self.mapView.userLocation.coordinate.latitude)%2C\(self.mapView.userLocation.coordinate.longitude)&endcoord=\(self.mkPlace.coordinate.latitude)%2C\(self.mkPlace.coordinate.longitude)")! as URL);
            }
            else {
                UIApplication.shared.openURL(NSURL(string:"itms-apps://itunes.apple.com/app/bars/id469463298")! as URL);
            }
            alert.dismiss(animated: true, completion: nil);
        }));
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Annulation");
            alert.dismiss(animated: true, completion: nil)
        }));
        self.parent?.present(alert, animated: true, completion: nil);
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
            return distance.rounded()
        }
        return -1;
    }

    
    override func viewDidAppear(_ animated: Bool) {
        let alert = UIAlertController(title: nil, message: Texts.waiting, preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped             = true
        loadingIndicator.activityIndicatorViewStyle   = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        //self.present(alert, animated: true, completion: nil);
        self.getCriterias();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //--- CriteriaCollectionView
    //
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return criterias.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "resultMapCollectionCell", for: indexPath) as! ResultMapCriteriaCollectionViewCell
        cell.configure(criteria: criterias[indexPath.row]);
        if criterias[indexPath.row].name == "Zone de détente" {
            cell.setSelected(criteria: criterias[indexPath.row]);
            self.isPlacesSelecred = true;
        }
        return cell;
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPlace) {
            let p = overlay as! MKPlace;
            let place = MKPolygonRenderer(overlay: p.polygon);
            place.fillColor   = UIColor.init(hexString: p.place.backgroundColor);
            place.strokeColor = UIColor.init(hexString: p.place.borderColor);
            place.alpha       = 0.3;
            place.lineWidth   = 1;
            return place;
        }
        return MKPolygonRenderer(overlay: overlay);
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            //annotationView.canShowCallout = true
            if annotation is MKPin {
                let image = UIImage(bgIcon: FAType(rawValue : (annotation as! MKPin).criteria.codeFA)!, bgTextColor: UIColor.white, bgBackgroundColor: UIColor.white, topIcon: FAType(rawValue : (annotation as! MKPin).criteria.codeFA)!, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 20, height: 20));
                annotationView.addSubview(UIImageView(image: image));
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: 20,y: 20), radius: CGFloat(25), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = circlePath.cgPath
                //change the fill color
                shapeLayer.fillColor = UIColor(hexString: (annotation as! MKPin).criteria.frontColor).cgColor;
                //you can change the stroke color
                shapeLayer.strokeColor = UIColor.white.cgColor;
                //you can change the line width
                shapeLayer.lineWidth = 3.0;
                if ((annotationView.layer.sublayers?.count)! >= 2) {
                    while((annotationView.layer.sublayers?.count)! > 1) {
                        annotationView.layer.sublayers?.remove(at: 0)
                    }
                    annotationView.layer.insertSublayer(shapeLayer, at: 0);
                }
                else {
                    annotationView.layer.insertSublayer(shapeLayer, at: 0);
                }
            }
            else if annotation is MKUserLocation {
                return nil
            }
        }
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        /*self.chevronUpDown.isHidden = false;
        self.animateChevronUpDown(up : true);
        let center = view.annotation?.coordinate;
        let region = MKCoordinateRegion(center: center!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
        self.mapView.setRegion(region, animated: true);
        
        // Add animation on image*/
    }
    
    @IBAction func chevronLeftRight(_ sender: UIButton) {
        let screenSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64);
        if sender.currentImage?.size.width == 48 {
            UIView.animate(withDuration: 0.4, animations: {
                self.criteriaCollectionView.frame.origin.x = screenSize.width - self.criteriaCollectionView.frame.size.width;
                sender.frame.origin.x -= self.criteriaCollectionView.frame.size.width;
            })
            sender.setImage(UIImage(bgIcon: FAType.FAChevronCircleRight, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FAChevronCircleRight, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 25, height: 25)), for: UIControlState.normal);
        }
        else {
            UIView.animate(withDuration: 0.4, animations: {
                self.criteriaCollectionView.frame.origin.x = screenSize.width;
                sender.frame.origin.x += self.criteriaCollectionView.frame.size.width;
            })
            sender.setImage(UIImage(bgIcon: FAType.FAChevronCircleLeft, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FAChevronCircleLeft, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 24, height: 25)), for: UIControlState.normal);
        }
    }
    
    @IBAction func chevronUpDown(_ sender: UIButton) {
        if sender.currentImage?.size.width == 110 {
            self.animateChevronUpDown(up: false);
        }
        else {
            self.animateChevronUpDown(up: true);
        }
    }
    
    func animateChevronUpDown(up: Bool){
        let screenSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64);
        if (up) {
            if(self.mapContainer.frame.size.height == screenSize.height){
                UIView.animate(withDuration: 0.4, animations: {
                    var mapFrame = self.mapContainer.frame;
                    mapFrame.size.height -= self.dataContainer.frame.size.height - 55;
                    
                    var dataFrame = self.dataContainer.frame;
                    dataFrame.origin.y = UIScreen.main.bounds.size.height - (self.dataContainer.frame.size.height);
                    
                    self.mapContainer.frame = mapFrame;
                    self.mapView.frame.size.height = mapFrame.size.height;
                    self.criteriaCollectionView.frame.size.height = mapFrame.size.height;
                    
                    self.dataContainer.frame = dataFrame;
                })
                
                self.chevronUpDown.setImage(UIImage(bgIcon: FAType.FAChevronDown, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FAChevronDown, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 55, height: 55)), for: UIControlState.normal);
            }
        }
        else {
            UIView.animate(withDuration: 0.4, animations: {
                var mapFrame = self.mapContainer.frame;
                mapFrame.size.height = screenSize.height;
                
                var dataFrame = self.dataContainer.frame;
                dataFrame.origin.y = UIScreen.main.bounds.size.height - 55;
                
                self.mapContainer.frame = mapFrame;
                self.mapView.frame.size.height = mapFrame.size.height;
                self.criteriaCollectionView.frame.size.height = mapFrame.size.height;
                
                self.dataContainer.frame = dataFrame;
            })
            self.chevronUpDown.setImage(UIImage(bgIcon: FAType.FAChevronUp, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FAChevronUp, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 54, height: 55)), for: UIControlState.normal);
        }
    }
    
    func switchAction(cell: ResultMapCriteriaCollectionViewCell) {
        if(cell.selectedCriteria)
        {
            if(self.annotations[cell.criteria.name]?.count == 0) {
                let alert = UIAlertController(title: nil, message: Texts.waiting, preferredStyle: .alert)
                
                alert.view.tintColor = UIColor.black
                let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                loadingIndicator.startAnimating();
                alert.view.addSubview(loadingIndicator)
                //self.present(alert, animated: true, completion: nil);
                
                self.getCriteriaDatas(criteria: cell.criteria);
            }
            else {
                self.displayCriterias(display: true, criteriaName: cell.criteria.name);
            }
        }
        else
        {
            self.displayCriterias(display: false, criteriaName: cell.criteria.name);
        }
    }
    
    func displayCriterias(display: Bool, criteriaName: String) {
        if(display) {
            if (criteriaName != "Zone de détente") {
                print("A");
                self.mapView.addAnnotations(self.annotations[criteriaName]!);
            }
            else {
                print("B");
                self.mapView.add(self.mkPlace);
            }
        }
        else {
            if (criteriaName != "Zone de détente") {
                print("C");
                self.mapView.removeAnnotations(self.annotations[criteriaName]!);
            }
            else {
                print("D");
                self.mapView.remove(self.mkPlace);
            }
        }
    }
    
    func getCriterias()
    {
        print("GET /criterias");
        let request = NSMutableURLRequest(url: URL(string: Server.url + "criterias")!);
        request.httpMethod="GET";
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            
            if error != nil
            {
                return
            }
            
            let place = Criteria(id: 0, name: "Zone de détente", category: "none", backgroundColor: "#FFFFFF", frontColor: "#991111", codeFA: 176);
            OperationQueue.main.addOperation {
                do{
                    self.criterias.removeAll();
                    self.criterias.append(place);
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    for item in json
                    {
                        let criteria = item as! [String:AnyObject];
                        let id = criteria["id"] as! Int;
                        let name = criteria["name"] as! String;
                        let category = criteria["category"] as! String;
                        let backgroundColor = criteria["backgroundColor"] as! String;
                        let frontColor = criteria["frontColor"] as! String;
                        let codeFa = criteria["codeFA"] as! Int;
                        let isEquipment = criteria["isEquipment"] as! Bool;
                        
                        if (isEquipment && name != "Arbre" || name=="Restaurant" || name=="Bar") {
                            self.criterias.append(Criteria(id: id, name: name, category: category, backgroundColor: backgroundColor, frontColor: frontColor, codeFA: codeFa));
                            self.annotations[name] = [MKAnnotation]();
                        }
                    }
                }catch {
                    OperationQueue.main.addOperation {
                        self.dismiss(animated: true, completion: {
                            let alertController = UIAlertController(title: Texts.error, message: Texts.alertServerProblem, preferredStyle: UIAlertControllerStyle.alert)
                            let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                            
                            alertController.addAction(cancel)
                            
                            if self.presentedViewController == nil {
                                self.present(alertController, animated: true, completion: nil)
                            }
                        })
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.criteriaCollectionView.reloadData();
                })
            }
        })
        task.resume();
        
    }
    
    
    func getCriteriaDatas(criteria: Criteria) {
        print("GET /criteriaNames");
        let request = NSMutableURLRequest(url: URL(string: Server.url + "equipments?criteria=\(criteria.id)")!);
        request.httpMethod="GET";
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            
            if error != nil
            {
                OperationQueue.main.addOperation {
                    self.dismiss(animated: true, completion: {
                        let alertController = UIAlertController(title: Texts.error, message: Texts.alertInternetOffline, preferredStyle: UIAlertControllerStyle.alert)
                        let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        
                        alertController.addAction(cancel)
                        
                        if self.presentedViewController == nil {
                            self.present(alertController, animated: true, completion: nil)
                        }
                    })
                    
                }
                return
            }
            
            OperationQueue.main.addOperation {
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    for item in json
                    {
                        let datas = item as! [String:AnyObject];
                        let id    = datas["id"] as! Int;
                        let name  = datas["name"] as! String;
                        let array = datas["coordinate"] as! [String:AnyObject];
                        let lat   = array["latitude"] as! Double;
                        let lng   = array["longitude"] as! Double;
                        
                        let pin = MKPin.init(criteria: criteria);
                        pin.coordinate.latitude  = lat;
                        pin.coordinate.longitude = lng;
                        self.annotations[criteria.name]?.append(pin);
                    }
                    self.displayCriterias(display: true, criteriaName: criteria.name);
                }catch {
                    OperationQueue.main.addOperation {
                        self.dismiss(animated: true, completion: {
                            let alertController = UIAlertController(title: Texts.error, message: Texts.alertServerProblem, preferredStyle: UIAlertControllerStyle.alert)
                            let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                            
                            alertController.addAction(cancel)
                            
                            if self.presentedViewController == nil {
                                self.present(alertController, animated: true, completion: nil)
                            }
                        })
                        
                    }
                }
                DispatchQueue.main.async(execute: {
                    
                })
            }
            
        })
        task.resume();
        
    }


}
