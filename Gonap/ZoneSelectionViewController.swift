//
//  ZoneSelectionViewController.swift
//  Gonap
//
//  Created by Antoine Payan on 21/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit

class ZoneSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate=self;
        self.tableView.dataSource=self;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let defaults = UserDefaults.standard;
        if let data = defaults.object(forKey: "places") as? Data {
            var places = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Place];
            return places.count;
        }
        else
        {
            return 0;
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaults = UserDefaults.standard;
        
        if let data = defaults.object(forKey: "places") as? Data {
            var places = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Place];
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPlace", for: indexPath);
            cell.accessoryType = .disclosureIndicator;
            cell.textLabel?.text=places[indexPath.row].name;
            return cell;
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPlace", for: indexPath);
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "criteriaSelection", sender: indexPath);
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "criteriaSelection"
        {
            let vc = segue.destination as! CollectionCommentViewController
            let send = sender as! IndexPath
            let defaults = UserDefaults.standard;
            if let data = defaults.object(forKey: "places") as? Data {
                var places = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Place];
                vc.place=places[send.row];
            }
            
        }
    }
    

}
