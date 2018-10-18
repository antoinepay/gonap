//
//  MenuIndexViewController.swift
//  Gonap
//
//  Created by Cristol Luc on 11/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class MenuIndexViewController: UITableViewController {

    @IBOutlet weak var settings: UILabel!
    @IBOutlet weak var mapZones: UILabel!
    @IBOutlet weak var searchZones: UILabel!
    @IBOutlet weak var suggestion: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settings.setFAText(prefixText: "", icon: FAType.FACogs, postfixText: " Réglages", size: 24);
        self.mapZones.setFAText(prefixText: " ", icon: FAType.FAMapPin, postfixText: " Zones", size: 24);
        self.searchZones.setFAText(prefixText: "", icon: FAType.FASearch, postfixText: " Recherche", size: 24);
        self.suggestion.setFAText(prefixText: "", icon: FAType.FAComment, postfixText: " Suggérer", size: 24);
        
        for c in self.tableView.visibleCells
        {
            c.contentView.frame = CGRect(x: 10, y: 0, width: c.contentView.frame.width-20, height: c.contentView.frame.height);
            c.contentView.layer.cornerRadius=5.0;
            c.contentView.clipsToBounds=true;
        }
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for c in self.tableView.visibleCells
        {
            c.contentView.backgroundColor = UIColor.clear
        }
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        UIView.animate(withDuration: 0.5) {
            selectedCell.contentView.backgroundColor = UIColor.init(hexString: "#DDDDDD")
        }
        
    }
    
    // if tableView is set in attribute inspector with selection to multiple Selection it should work.
    
    // Just set it back in deselect

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
