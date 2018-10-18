//
//  CriteriaListViewController.swift
//  Gonap
//
//  Created by Antoine Payan on 11/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
import MapKit

class CriteriaListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var validateCriteria: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var criterias : [Criteria] = [];
    var categories : [Category] = [];
    var categoriesInSection : [Int:Int] = [:];
    var criteriasSelected : [Criteria:Int] = [:];
    var critFound : [Place] = [];
    var values : [Value] = [];
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate=self;
        self.tableView.dataSource=self;
        
        if self.revealViewController() != nil {
            menuButton.FAIcon=FAType.FABars;
            menuButton.image=nil;
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        
        self.validateCriteria.backgroundColor=UIColor.init(hexString: Colors.green);
        self.validateCriteria.titleLabel?.textColor=UIColor.white;
        self.validateCriteria.tintColor=UIColor.white;
        self.validateCriteria.titleLabel!.text="Valider le choix"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData();
        self.criteriasSelected.removeAll();
        self.critFound.removeAll();
        self.validateCriteria.isEnabled=false;
        self.validateCriteria.isOpaque=true;
        let alert = UIAlertController(title: nil, message: Texts.waiting, preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil);
        self.getCriteria();
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.categories.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "criteriasCell", for: indexPath) as! CategoryCriteriaTableViewCell;
        var criterias = [Criteria]();
        for c in categories
        {
            if categoriesInSection[indexPath.section]==c.id
            {
                criterias = c.criterias;
            }
        }
        cell.configure(criterias : criterias, selected: criteriasSelected);
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let categoryName = categories[section].name;
        let codeIcon = categories[section].criterias[0].codeFA;
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 40))
        let icone = UIImageView.init(image: UIImage.init(icon: FAType.init(rawValue: codeIcon)!, size: CGSize.init(width: 32, height: 32), textColor: UIColor.red, backgroundColor: UIColor.clear));
        icone.frame.origin=CGPoint.init(x: 20, y: 4);
        let title = UILabel.init(frame: CGRect.init(x: 60, y: 0, width: Int(self.view.frame.width/2), height: 40));
        title.text=categoryName;
        title.font=UIFont.boldSystemFont(ofSize: 16.0);
        headerView.backgroundColor=UIColor.init(hexString: "#FAFAFA");
        headerView.addSubview(icone);
        headerView.addSubview(title);
        return headerView;
    }
    
    
    func getCriteria()
    {
        let request = NSMutableURLRequest(url: URL(string: Server.url + "categories")!);
        request.httpMethod="GET";
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            
            if error != nil
            {
                OperationQueue.main.addOperation {
                    self.dismiss(animated: true, completion: nil)
                    let alertController = UIAlertController(title: Texts.error, message: Texts.alertInternetOffline, preferredStyle: UIAlertControllerStyle.alert)
                    let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    
                    alertController.addAction(cancel)
                    
                    if self.presentedViewController == nil {
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                }
                return
            }
            
            OperationQueue.main.addOperation {
                do{
                    self.categories.removeAll();
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    for item in json
                    {
                        let category = item as! [String:AnyObject];
                        let id = category["id"] as! Int;
                        let name = category["name"] as! String;
                        let criterias = category["criterias"] as! [AnyObject];
                        var criteriasArray = [Criteria]();
                        for criteria in criterias
                        {
                            let crit = criteria as! [String:AnyObject]
                            let critId = crit["id"] as! Int;
                            let critName = crit["name"] as! String;
                            let frontColor = crit["frontColor"] as! String;
                            let codeFa = crit["codeFA"] as! Int;
                            criteriasArray.append(Criteria(id: critId, name: critName, category: name, backgroundColor: "#FFFFFF", frontColor: frontColor, codeFA: codeFa));
                        }
                        let cat = Category(id : id, name: name, criterias: criteriasArray);
                        self.categories.append(cat);
                    }
                    var i = 0;
                    for c in self.categories
                    {
                        for crit in c.criterias
                        {
                            self.criteriasSelected[crit]=0;
                        }
                        self.categoriesInSection[i]=c.id;
                        i+=1;
                    }
                }catch {
                    OperationQueue.main.addOperation {
                        let alertController = UIAlertController(title: Texts.error, message: Texts.alertServerProblem, preferredStyle: UIAlertControllerStyle.alert)
                        let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        
                        alertController.addAction(cancel)
                        
                        if self.presentedViewController == nil {
                            self.present(alertController, animated: true, completion: nil)
                        }
                        
                    }
                }
                self.dismiss(animated: true, completion: nil)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
        })
        task.resume();
    }

    @IBAction func validateCriteria(_ sender: UIButton)
    {
        let alert = UIAlertController(title: nil, message: Texts.waiting, preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil);
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        if let locationManager = appDelegate.locationManager {
            jsonObject.setValuesForKeys(["latitude":locationManager.location?.coordinate.latitude,"longitude":locationManager.location?.coordinate.longitude]);
            var critSelected : [[String:Int]] = [];
            for value in criteriasSelected
            {
                if(value.value > 0)
                {
                    critSelected.append(["id":value.key.id,"value":value.value]);
                    }
            }
            jsonObject.setValue(critSelected, forKey: "criterias");

            let jsonData: NSData
            
            do {
                jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
                let request = NSMutableURLRequest(url: URL(string: Server.url + "find")!);
                request.httpMethod="POST";
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody=jsonData as Data;
                let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
                    data, response, error in
                    
                    if error != nil
                    {
                        OperationQueue.main.addOperation {
                            alert.removeFromParentViewController();
                            let alertController = UIAlertController(title: Texts.error, message: Texts.alertInternetOffline, preferredStyle: UIAlertControllerStyle.alert)
                            let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                            
                            alertController.addAction(cancel)
                            
                            if self.presentedViewController == nil {
                                self.present(alertController, animated: true, completion: nil)
                            }
                            
                        }
                        return
                    }
                    
                    OperationQueue.main.addOperation {
                        do
                        {
                            let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                            if json.count > 0
                            {
                                let pls = json["places"] as! NSArray;
                                for item in pls
                                {
                                    let it = item as! [String:AnyObject];
                                    var boundaries = [CLLocationCoordinate2D]();
                                    var startZero = false;
                                    var tmp = [Int:CLLocationCoordinate2D]();
                                    for b in it["boundaries"] as! NSArray
                                    {
                                        let latlng = b as! [String:AnyObject];
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
                                    var feedbacks = [Feedback]();
                                    let fs = it["feedbacks"] as! NSArray
                                    for f in fs
                                    {
                                        let feed = f as! [String:AnyObject];
                                        let feedbackType = feed["FeedbackType"] as! [String:AnyObject]
                                        feedbacks.append(Feedback(id: feedbackType["id"] as! Int, name: feedbackType["name"] as! String, duration: feedbackType["duration"] as! Int))
                                    }
                                    let pl = Place(id: it["id"] as! Int, name: it["name"] as! String, borderColor: it["borderColor"] as! String, backgroundColor: it["backgroundColor"] as! String, boundaries: boundaries)
                                    pl.rate=it["rating"] as! Double;
                                    pl.travelTime=it["travel_time"] as! Double;
                                    pl.travelDistance=it["travel_distance"] as! Int;
                                    pl.feedbacks=feedbacks;
                                    self.critFound.append(pl);
                                }
                                let values = json["values"] as! NSArray
                                for v in values
                                {
                                    let value = v as! [String:AnyObject];
                                    let placeId = value["PlaceId"] as! Int;
                                    let crit = value["Criteria"] as! NSDictionary
                                    let critName = crit["name"] as! String;
                                    let rating = value["value"] as! Double;
                                    self.values.append(Value(place: placeId, criteria: critName, rating: rating/2));
                                }
                                self.dismiss(animated: true, completion: nil)
                                self.performSegue(withIdentifier: "findPlaces", sender: self);
                            }
                            else
                            {
                                self.dismiss(animated: true, completion: {
                                    let alertController = UIAlertController(title: Texts.error, message: Texts.alertInternetOffline, preferredStyle: UIAlertControllerStyle.alert)
                                    let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                                    
                                    alertController.addAction(cancel)
                                    
                                    if self.presentedViewController == nil {
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                })
                            }
                        }catch{
                            print("Problem JSON");
                        }
                    }
                })
                task.resume();
                
            } catch _ {
                print ("JSON Failure")
            }
        }
        

        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "findPlaces"
        {
            let vc = segue.destination as! PlacesCriteriaViewController
            vc.places=critFound;
            vc.values=values;
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
