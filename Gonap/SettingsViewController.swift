//
//  SettingsViewController.swift
//  Gonap
//
//  Created by Antoine Payan on 12/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class SettingsViewController: UIViewController {

    @IBOutlet weak var mapTypeSegment: UISegmentedControl!
    @IBOutlet weak var clearPlacesButton: UIButton!
    @IBOutlet weak var deleteHistoryButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.FAIcon=FAType.FABars;
            menuButton.image=nil;
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        self.deleteHistoryButton.setTitleColor(UIColor.init(hexString: Colors.redGL), for: .normal)
        let defaults = UserDefaults.standard;
        if let mapType = defaults.integer(forKey: "mapType") as? Int
        {
            mapTypeSegment.selectedSegmentIndex=mapType;
        }
        else
        {
            mapTypeSegment.selectedSegmentIndex=0;
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteHistory(_ sender: Any) {
        let defaults = UserDefaults.standard;
        defaults.removeObject(forKey: "places");
        defaults.synchronize();

    }

    @IBAction func clearButton(_ sender: UIButton)
    {
        let defaults = UserDefaults.standard;
        defaults.removeObject(forKey: "allPlaces");
        defaults.synchronize();
    }
    @IBAction func changeMapType(_ sender: Any)
    {
        let defaults = UserDefaults.standard;
        defaults.set(mapTypeSegment.selectedSegmentIndex, forKey: "mapType");
        defaults.synchronize();
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
