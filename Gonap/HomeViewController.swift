//
//  HomeViewController.swift
//  Gonap
//
//  Created by Antoine Payan on 04/05/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    var imageView : UIImageView!;
    var buttonContinue : UIButton!;
    var buttonReset : UIButton!;
    var gonapLabel : UILabel!;
    var reset = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let imageName = "LaunchScreen"
        let image = UIImage(named: imageName)
        imageView = UIImageView(image: image!)
        let centerHori = Int(self.view.frame.width/2);
        let centerVerti = Int(self.view.frame.height/2);
        imageView.frame = CGRect(x: centerHori-150, y: centerVerti-120, width: 300, height: 240)
        self.view.addSubview(imageView);
        buttonContinue = UIButton();
        buttonContinue.frame = CGRect(x: 0, y: centerVerti-10, width: Int(self.view.frame.width), height: 60)
        buttonContinue.setTitleShadowColor(UIColor.black, for: .normal);
        buttonContinue.setTitleColor(UIColor.white, for: .normal)
        buttonContinue.setTitleColor(UIColor.gray, for: .highlighted)
        buttonContinue.titleLabel?.font=UIFont.boldSystemFont(ofSize: 20);
        buttonContinue.setTitle("Continuer mon activité", for: .normal)
        buttonContinue.alpha=0;
        buttonContinue.addTarget(self, action: #selector(self.globalMapNormal), for: .touchUpInside);
        self.view.addSubview(buttonContinue)
        
        buttonReset = UIButton();
        buttonReset.frame = CGRect(x: 0, y: centerVerti+80, width: Int(self.view.frame.width), height: 60)
        buttonReset.setTitleColor(UIColor.white, for: .normal)
        buttonReset.setTitleColor(UIColor.gray, for: .highlighted)
        buttonReset.titleLabel?.font=UIFont.boldSystemFont(ofSize: 20);
        buttonReset.setTitle("Recommencer une session", for: .normal)
        buttonReset.alpha=0;
        buttonReset.addTarget(self, action: #selector(self.globalMapReset), for: .touchUpInside)
        self.view.addSubview(buttonReset);
        
        gonapLabel = UILabel();
        gonapLabel.textColor=UIColor.white;
        gonapLabel.text="GONAP";
        gonapLabel.font=UIFont.boldSystemFont(ofSize: 36);
        gonapLabel.textAlignment = .center;
        gonapLabel.frame=CGRect(x: 0, y: 230, width: self.view.frame.width, height: 40);
        gonapLabel.alpha=0;
        self.view.addSubview(gonapLabel);
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 2, animations: {
            self.imageView.frame.origin.y -= 200;
        }, completion:{ _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.gonapLabel.alpha=1;
                self.buttonReset.alpha=1;
                self.buttonContinue.alpha=1;
            }, completion: nil)
        })
    }
    
    func globalMapReset()
    {
        self.reset=true;
        self.performSegue(withIdentifier: "HomeMapSegue", sender: self)
    }
    
    func globalMapNormal()
    {
        self.reset=false;
        self.performSegue(withIdentifier: "HomeMapSegue", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="HomeMapSegue"
        {
            if(self.reset)
            {
                let defaults = UserDefaults.standard;
                defaults.removeObject(forKey: "allPlaces");
                defaults.removeObject(forKey: "places");
                defaults.synchronize();
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
