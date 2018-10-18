//
//  CommentHomeViewController.swift
//  Gonap
//
//  Created by Antoine Payan on 20/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class CommentHomeViewController: UIViewController {

    @IBOutlet weak var chevronLabel: UILabel!
    @IBOutlet weak var titleLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.isEditable=false;
        titleLabel.textAlignment = .center;
        titleLabel.isScrollEnabled=false;
        titleLabel.isSelectable=false;
        let total = NSMutableAttributedString(string : "");
        let help = NSAttributedString(string: "Aidez", attributes: [NSForegroundColorAttributeName:UIColor.init(hexString: Colors.redGL),NSFontAttributeName: UIFont.systemFont(ofSize: 30)]);
        let us = NSAttributedString(string: " - nous", attributes: [NSForegroundColorAttributeName:UIColor.lightGray,NSFontAttributeName: UIFont.systemFont(ofSize: 30)]);
        self.chevronLabel.setFAText(prefixText: "Glissez ", icon: FAType.FAArrowRight, postfixText: "", size: 20);
        self.chevronLabel.setFAColor(color: UIColor.gray);
        total.append(help);
        total.append(us);
        self.titleLabel.attributedText=total;

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.parent?.navigationItem.title="Votre avis compte";
        // Standard font size
        let barName = UIBarButtonItem();
        
        // Custom font size
        barName.setFAIcon(icon: .FAWarning, iconSize: 24)
        
        barName.tintColor = .orange
        
        barName.action=#selector(self.goToFeedbacks);
        barName.target=self;
        self.parent?.navigationItem.rightBarButtonItem=barName;
        self.parent?.navigationItem.rightBarButtonItem?.isEnabled=true;

    }
    
    func goToFeedbacks()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if(appDelegate.inZone)
        {
            self.performSegue(withIdentifier: "notificationsCenterSegue", sender: self);
        }
        else
        {
            let alertController = UIAlertController(title: Texts.error, message: Texts.notInZone, preferredStyle: UIAlertControllerStyle.alert)
            let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
            alertController.addAction(cancel)
            
            if self.presentedViewController == nil {
                self.present(alertController, animated: true, completion: nil)
            }

        }
        
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
