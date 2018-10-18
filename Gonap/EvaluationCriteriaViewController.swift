//
//  EvaluationCriteriaViewController.swift
//  Gonap
//
//  Created by Antoine Payan on 26/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class EvaluationCriteriaViewController: UIViewController {

    @IBOutlet weak var sendComment: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explanationTextView: UITextView!
    
    @IBOutlet weak var criteriaName: UILabel!
    @IBOutlet weak var grade: UILabel!
    @IBOutlet weak var plus: UIButton!
    @IBOutlet weak var less: UIButton!
    var criteria : Criteria!;
    var place : Place!;
    var note : Int = 5;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text=""
        self.navigationItem.title=criteria.name;
        self.titleLabel.text=place.name;
        self.explanationTextView.text="Qu'avez-vous pensé du critère suivant ?"
        self.criteriaName.text=criteria.name;
        self.criteriaName.textColor=UIColor(hexString: criteria.frontColor);
        
        self.plus.setFAIcon(icon: FAType.FAPlus, iconSize: 40, forState: .normal)
        self.plus.setFATitleColor(color: UIColor(hexString: Colors.green));
        self.plus.layer.cornerRadius=45;
        self.plus.layer.borderWidth=3.0;
        self.plus.layer.borderColor=UIColor(hexString:Colors.green).cgColor;
        self.plus.addTarget(self, action: #selector(self.addGrade), for: .touchUpInside);
        
        self.less.setFAIcon(icon: FAType.FAMinus, iconSize: 40, forState: .normal)
        self.less.setFATitleColor(color: UIColor(hexString: Colors.redGL));
        self.less.layer.cornerRadius=45;
        self.less.layer.borderWidth=3.0;
        self.less.layer.borderColor=UIColor(hexString:Colors.redGL).cgColor;
        self.less.addTarget(self, action: #selector(self.subGrade), for: .touchUpInside);
        
        
        self.grade.text=String(note)+"/10";
        
        self.sendComment.setFAText(prefixText: "Envoyer ma note ", icon: FAType.FASend, postfixText: "", size: 20, forState: .normal);
        self.sendComment.tintColor=UIColor.white;
        self.sendComment.backgroundColor=UIColor(hexString: Colors.green);
        self.sendComment.layer.cornerRadius=5.0;
        self.sendComment.addTarget(self, action: #selector(self.sendNoteToCheck), for: .touchUpInside);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addGrade()
    {
        if(note<10)
        {
            note += 1;
            self.grade.text=String(note)+"/10";
        }
    }
    
    func subGrade()
    {
        if(self.note>0)
        {
            note -= 1;
            self.grade.text=String(note)+"/10";
        }
    }
    
    func sendNoteToCheck()
    {
        let alert = UIAlertController(title: nil, message: Texts.waiting, preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil);
        
        //Request
        let request = NSMutableURLRequest(url: URL(string: Server.url + "comments")!);
        request.httpMethod="POST";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        
        jsonObject.setValue(note, forKey: "rating")
        jsonObject.setValue(place.id, forKey: "place")
        jsonObject.setValue(criteria.id, forKey: "criteria")
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
            request.httpBody=jsonData as Data;
            
        } catch _ {
            print ("JSON Failure")
        }
        
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
                
                do
                {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    if json.count == 0
                    {
                        DispatchQueue.main.async(execute: {
                            self.dismiss(animated: true, completion: {
                                self.navigationController?.popViewController(animated: true);
                            })
                            //self.tableView.reloadData()
                        })
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
                        
                    }
                }
            })
        task.resume();
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
