//
//  NotificationsCenterTableViewController.swift
//  Gonap
//
//  Created by Antoine Payan on 26/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class FeedbacksTableViewController: UITableViewController {

    var feedbacks : [Feedback] = [];
    var place : Place!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        place = (UIApplication.shared.delegate as! AppDelegate).placeIn;
        self.tableView.delegate=self;
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getFeedbacks()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return feedbacks.count;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellComment", for: indexPath);
        cell.textLabel?.text=feedbacks[indexPath.row].name;
        cell.accessoryView=UIImageView.init(image: UIImage(icon: FAType.FAWarning, size: CGSize.init(width: 24, height: 24), textColor: UIColor.orange, backgroundColor: UIColor.clear));
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Confirmation", message: "Etes-vous sûr de vouloir envoyer cette alerte ?", preferredStyle: UIAlertControllerStyle.alert)
        let confirm = UIAlertAction(title: "Oui", style: .default, handler: {(alert: UIAlertAction!) in
            self.sendFeedback(feedback_id: self.feedbacks[indexPath.row].id);
        })
        let cancel = UIAlertAction(title: "Non", style: .cancel, handler: {(alert: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil);
        })
        
        alertController.addAction(confirm);
        alertController.addAction(cancel);
        
        if self.presentedViewController == nil {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func getFeedbacks()
    {
        let alert = UIAlertController(title: nil, message: Texts.waiting, preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil);
        
        let request = NSMutableURLRequest(url: URL(string: Server.url + "feedbacktypes")!);
        request.httpMethod="GET";
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            
            if error != nil
            {
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
                return
            }
            
            OperationQueue.main.addOperation {
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    for item in json
                    {
                        let feedback = item as! [String:AnyObject];
                        let id = feedback["id"] as! Int;
                        let name = feedback["name"] as! String;
                        let duration = feedback["duration"] as! Int;
                        self.feedbacks.append(Feedback(id : id,name: name, duration: duration));
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
                self.dismiss(animated: true, completion: nil)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData();
                })
            }
        })
        task.resume();

    }
    
    func sendFeedback(feedback_id : Int)
    {
        let alert = UIAlertController(title: nil, message: Texts.waiting, preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil);
        
        let request = NSMutableURLRequest(url: URL(string: Server.url + "feedbacks")!);
        request.httpMethod="POST";
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        
        jsonObject.setValue(place.id, forKey: "place_id")
        jsonObject.setValue(feedback_id, forKey: "feedback_type_id")
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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
