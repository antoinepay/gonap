//
//  MapCommentViewController.swift
//  Gonap
//
//  Created by Antoine Payan on 20/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit

class CollectionCommentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var criterias = [Criteria]();
    var place : Place!;
    var criteriaSelected : Criteria!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate=self;
        self.collectionView.dataSource=self;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let alert = UIAlertController(title: nil, message: Texts.waiting, preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil);
        self.getCriterias();
    }

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return criterias.count;
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectionCellCriteria", for: indexPath) as! SelectionCriteriaCollectionViewCell
        cell.configure(criteria: criterias[indexPath.row]);
        return cell;
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SelectionCriteriaCollectionViewCell;
        self.criteriaSelected=cell.criteria;
        self.performSegue(withIdentifier: "criteriaCommentSelected", sender: self);
    }
    
    
    
    func getCriterias()
    {
        let request = NSMutableURLRequest(url: URL(string: Server.url + "criterias")!);
        request.httpMethod="GET";
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            
            if error != nil
            {
                self.dismiss(animated: true, completion: nil);
                return
            }
            OperationQueue.main.addOperation {
                do{
                    self.criterias.removeAll();
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSArray
                    let indexPath = IndexPath(row: 0, section: 0);
                    for item in json
                    {
                        let criteria = item as! [String:AnyObject];
                        let id = criteria["id"] as! Int;
                        let name = criteria["name"] as! String;
                        let category = criteria["category"] as! String;
                        let backgroundColor = criteria["backgroundColor"] as! String;
                        let frontColor = criteria["frontColor"] as! String;
                        let codeFa = criteria["codeFA"] as! Int;
                        let equipment = criteria["isEquipment"] as! Bool;
                        if(!equipment)
                        {
                            self.criterias.append(Criteria(id: id, name: name, category: category, backgroundColor: backgroundColor, frontColor: frontColor, codeFA: codeFa));
                        }
                    }
                    self.dismiss(animated: true, completion: nil);
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
                    self.collectionView.reloadData();
                })
            }
        })
        task.resume();
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "criteriaCommentSelected"
        {
            let vc = segue.destination as! EvaluationCriteriaViewController
            vc.criteria=self.criteriaSelected;
            vc.place=self.place;
        }
    }
    

}
