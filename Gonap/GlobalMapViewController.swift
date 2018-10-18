//
//  ViewController.swift
//  Gonap
//
//  Created by Antoine Payan on 10/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import MapKit
import Font_Awesome_Swift

class GlobalMapViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate, UIGestureRecognizerDelegate{

    @IBOutlet weak var menuButton            : UIBarButtonItem!
    @IBOutlet weak var mapView               : MKMapView!
    @IBOutlet weak var mapContainer          : UIView!
    @IBOutlet weak var dataContainer         : UIView!
    @IBOutlet      var criteriaCollectionView: UICollectionView!
    @IBOutlet weak var chevronUpDown         : UIButton!
    @IBOutlet weak var chevronLeftRight      : UIButton!
    
    @IBOutlet weak var mapColorImage: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var address2Label: UILabel!
    @IBOutlet weak var address3Label: UILabel!
    @IBOutlet weak var timeTravelImage: UIImageView!
    @IBOutlet weak var timeTravelLabel: UILabel!
    @IBOutlet weak var distanceTravelLabel: UILabel!
    @IBOutlet weak var distanceTravelImage: UIImageView!
    
    var isPlacesSelecred : Bool!;
    
    var criterias   : [Criteria]              = [];
    var places      : [MKPlace]               = [];
    var annotations : [String:[MKAnnotation]] = [:];
    var selectedPlace : MKPlace!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate                  = self;
        self.criteriaCollectionView.delegate   = self;
        self.criteriaCollectionView.dataSource = self;
        self.criteriaCollectionView.backgroundColor = UIColor.clear;
        if self.revealViewController() != nil {
            menuButton.FAIcon = FAType.FABars;
            menuButton.image  = nil;
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        
        let locationManager = (UIApplication.shared.delegate as! AppDelegate).locationManager;
        self.timeTravelLabel.removeFromSuperview()
        self.timeTravelImage.removeFromSuperview()
        self.distanceTravelLabel.removeFromSuperview()
        self.distanceTravelImage.removeFromSuperview()
        //--- MapView settings
        //
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
        }
        if let location = locationManager?.location?.coordinate
        {
            mapView.setCenter(location, animated: false);
            var mapPoint = MKMapPoint();
            let mapSize = MKMapSize(width: 10000, height: 10000);
            mapPoint = MKMapPointForCoordinate((locationManager?.location?.coordinate)!);
            mapPoint.x-=5000;
            mapPoint.y-=5000;
            let mapRect = MKMapRect.init(origin: mapPoint, size: mapSize);
            mapView.setVisibleMapRect(mapRect, animated: false);
        }
        
        let defaults = UserDefaults.standard;
        if let mapType = defaults.object(forKey: "mapType") as? Int
        {
            mapView.mapType=MKMapType.init(rawValue: UInt(mapType))!;
        }
        else
        {
            mapView.mapType=MKMapType.init(rawValue: 0)!;
        }
        
        mapView.showsCompass      = false;
        mapView.showsUserLocation = true;
        mapView.showsBuildings    = true;
        mapView.showsScale        = true;
        mapView.showsTraffic          = false;
        mapView.showsPointsOfInterest = false;
        
        mapView.isZoomEnabled   = true;
        mapView.isPitchEnabled  = true;
        mapView.isRotateEnabled = true;
        mapView.isScrollEnabled = true;
        
        self.chevronLeftRight.setImage(UIImage(bgIcon: FAType.FAChevronCircleRight, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FAChevronCircleRight, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 35, height: 35)), for: UIControlState.normal);
        self.chevronUpDown.setImage(UIImage(bgIcon: FAType.FAChevronDown, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FAChevronDown, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 55, height: 55)), for: UIControlState.normal);
        
        self.criteriaCollectionView.reloadData();
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:)));
        recognizer.delegate = self;
        self.mapView.addGestureRecognizer(recognizer);
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        let touchPoint = recognizer.location(in: mapView);
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView);
        for item in places {
            var array = [CGPoint]();
            for bound in item.place.boundaries {
                let point = CGPoint(x: bound.latitude, y: bound.longitude);
                array.append(point);
            }
            let coord = CGPoint(x: coordinates.latitude, y: coordinates.longitude);
            if(self.contains(polygon: array, test: coord) && self.isPlacesSelecred) {
                self.selectedPlace = item;
                self.initDataContainer();
                self.chevronUpDown.isHidden = false;
                self.animateChevronUpDown(up : true);
                let center = item.polygon.coordinate;
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
                self.mapView.setRegion(region, animated: true);
            }
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
    
    func initDataContainer() {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: selectedPlace.coordinate.latitude, longitude: selectedPlace.coordinate.longitude)
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
                self.address2Label.text = street as String;
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
        self.mapColorImage.image = UIImage(bgIcon: FAType.FACircle, bgTextColor: UIColor(hexString: selectedPlace.place.backgroundColor), bgBackgroundColor: UIColor.clear, topIcon: FAType.FACircle, topTextColor: UIColor(hexString: selectedPlace.place.backgroundColor), bgLarge: true, size: CGSize(width: 25, height: 25));
        self.placeNameLabel.text = selectedPlace.place.name;
        
        
    }
    
    @IBAction func goToPlace(_ sender: UIButton) {
        let alert = UIAlertController(title: "Par quel moyen ?", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Plans", style: .default, handler: { (action: UIAlertAction!) in
            UIApplication.shared.openURL(NSURL(string:"http://maps.apple.com/maps?saddr=\(self.mapView.userLocation.coordinate.latitude),\(self.mapView.userLocation.coordinate.longitude)&daddr=\(self.selectedPlace.coordinate.latitude),\(self.selectedPlace.coordinate.longitude)")! as URL);
            alert.dismiss(animated: true, completion: nil)
        }));
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
            alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { (action: UIAlertAction!) in
                UIApplication.shared.openURL(NSURL(string:
                    "comgooglemaps://?saddr=&daddr=\(self.selectedPlace.coordinate.latitude),\(self.selectedPlace.coordinate.longitude)&directionsmode=driving")! as URL)
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
                UIApplication.shared.openURL(NSURL(string:"citymapper://directions?startcoord=\(self.mapView.userLocation.coordinate.latitude)%2C\(self.mapView.userLocation.coordinate.longitude)&endcoord=\(self.selectedPlace.coordinate.latitude)%2C\(self.selectedPlace.coordinate.longitude)")! as URL);
            }
            else {
                UIApplication.shared.openURL(NSURL(string:"itms-apps://itunes.apple.com/app/bars/id469463298")! as URL);
            }
            alert.dismiss(animated: true, completion: nil);
        }));
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }));
        self.parent?.present(alert, animated: true, completion: nil);
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
        
        let defaults = UserDefaults.standard;
        
        if let data = defaults.object(forKey: "allPlaces") as? Data {
            let allPlaces = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Place];
            self.places.removeAll();
            for p in allPlaces
            {
                self.places.append(MKPlace(place: p));
            }
            self.displayCriterias(display : true, criteriaName: "Zones de détente");
        }
        else
        {
           self.getPlaces();
        }
        
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "globalMapCollectionCell", for: indexPath) as! GlobalMapCriteriaCollectionViewCell
        cell.configure(criteria: criterias[indexPath.row]);
        if criterias[indexPath.row].name == "Zones de détente" {
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
                let image = UIImage(bgIcon: FAType(rawValue : (annotation as! MKPin).criteria.codeFA)!, bgTextColor: UIColor.white, bgBackgroundColor: UIColor.white, topIcon: FAType(rawValue : (annotation as! MKPin).criteria.codeFA)!, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 14, height: 14));
                annotationView.addSubview(UIImageView(image: image));
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: 14,y: 14), radius: CGFloat(19), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
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
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        // Add Animation on image
    }
    
    /*func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Remove Pins when too much unzoom
        // TO DO : Add pins when zoom is enough depending off switch ON/OFF
        let zoomWidth = mapView.visibleMapRect.size.width;
        let zoomFactor = Int(log2(zoomWidth)) - 9;
        
        if(zoomFactor > 5) {
            for item in self.criterias {
                if (self.annotations[item.name] != nil) {
                    self.mapView.removeAnnotations(self.annotations[item.name]!);
                }
            }
        }
        else
        {
            for item in self.criterias {
                if (self.annotations[item.name] != nil) {
                    self.mapView.addAnnotations(self.annotations[item.name]!);
                }
            }
        }
    }*/
    
    @IBAction func chevronLeftRight(_ sender: UIButton) {
        let screenSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64);
        if sender.currentImage?.size.width == 48 {
            UIView.animate(withDuration: 0.4, animations: {
                self.criteriaCollectionView.frame.origin.x = screenSize.width - self.criteriaCollectionView.frame.size.width;
                sender.frame.origin.x -= self.criteriaCollectionView.frame.size.width;
            })
            sender.setImage(UIImage(bgIcon: FAType.FAChevronCircleRight, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FAChevronCircleRight, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 35, height: 35)), for: UIControlState.normal);
        }
        else {
            UIView.animate(withDuration: 0.4, animations: {
                self.criteriaCollectionView.frame.origin.x = screenSize.width;
                sender.frame.origin.x += self.criteriaCollectionView.frame.size.width;
            })
            sender.setImage(UIImage(bgIcon: FAType.FAChevronCircleLeft, bgTextColor: UIColor.black, bgBackgroundColor: UIColor.clear, topIcon: FAType.FAChevronCircleLeft, topTextColor: UIColor.clear, bgLarge: true, size: CGSize(width: 35, height: 35)), for: UIControlState.normal);
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
    
    func switchAction(cell: GlobalMapCriteriaCollectionViewCell) {
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
            if (criteriaName != "Zones de détente") {
                self.mapView.addAnnotations(self.annotations[criteriaName]!);
            }
            else {
                self.mapView.addOverlays(self.places);
            }
        }
        else {
            if (criteriaName != "Zones de détente") {
                self.mapView.removeAnnotations(self.annotations[criteriaName]!);
            }
            else {
                self.mapView.removeOverlays(self.places);
            }
        }
    }
    
    func getCriterias()
    {
        let request = NSMutableURLRequest(url: URL(string: Server.url + "criterias")!);
        request.httpMethod="GET";
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            
            if error != nil
            {
                return
            }
            
            let place = Criteria(id: 0, name: "Zones de détente", category: "none", backgroundColor: "#FFFFFF", frontColor: "#991111", codeFA: 176);
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
    
    func getPlaces()
    {
        let request = NSMutableURLRequest(url: URL(string: Server.url + "places")!);
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
                do{
                    self.places.removeAll();
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    for item in json
                    {
                        let place = item as! [String:AnyObject];
                        let id = place["id"] as! Int;
                        let name = place["name"] as! String;
                        let borderColor = place["borderColor"] as! String;
                        let backgroundColor = place["backgroundColor"] as! String;
                        var boundaries = [CLLocationCoordinate2D]();
                        var tmp = [Int:CLLocationCoordinate2D]();
                        let array = place["boundaries"] as! [AnyObject];
                        var startZero = false;
                        for item2 in array {
                            let latlng = item2  as! [String:AnyObject];
                            var lat = latlng["latitude"] as! Double;
                            var lng = latlng["longitude"] as! Double;
                            lat = round(100000*lat)/100000
                            lng = round(100000*lng)/100000
                            let nb  = latlng["number"] as! Int;
                            var boundary = CLLocationCoordinate2D();
                            boundary.latitude = lat;
                            boundary.longitude = lng;
                            tmp[nb] = boundary;
                            if(nb == 0) {
                                startZero = true;
                            }
                        }
                        var i = 1;
                        if(startZero) {
                            i = 0;
                            while(i < tmp.count) {
                                boundaries.append(tmp[i]!);
                                i += 1;
                            }
                        }
                        else {
                            while(i <= tmp.count) {
                                boundaries.append(tmp[i]!);
                                i += 1;
                            }
                        }
                        
                        let mkPlace = MKPlace(place: Place(id: id, name: name, borderColor: borderColor, backgroundColor: backgroundColor, boundaries: boundaries));
                        self.places.append(mkPlace);
                        
                    }
                    DispatchQueue.main.async(execute: {
                        let defaults = UserDefaults.standard;
                        var placesToStore = [Place]();
                        for p in self.places
                        {
                            placesToStore.append(p.place);
                        }
                        defaults.set(NSKeyedArchiver.archivedData(withRootObject: placesToStore), forKey: "allPlaces");
                        defaults.synchronize();
                        self.displayCriterias(display : true, criteriaName: "Zones de détente");
                    })
                    
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
        })
        task.resume();

    }

    func getCriteriaDatas(criteria: Criteria) {
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

}

