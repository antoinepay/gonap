//
//  AppDelegate.swift
//  Gonap
//
//  Created by Antoine Payan on 10/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import CoreData
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager : CLLocationManager!;
    var inZone : Bool = false;
    var placeIn : Place!;
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.removeObject(forKey: "allPlaces");
        self.initLocation();
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func initLocation()
    {
        self.locationManager = CLLocationManager();
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = 10
        locationManager.distanceFilter = 10;
        if #available(iOS 9.0, *) {
            self.locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        };
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let defaults = UserDefaults.standard;
        inZone=false;
        if let data = defaults.object(forKey: "allPlaces") as? Data {
            let allPlaces = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Place];
            for allP in allPlaces
            {
                if(locations.last?.coordinate.contained(by:allP.boundaries))!
                {
                    inZone = true;
                    self.placeIn=allP;
                    if let data = defaults.object(forKey: "places") as? Data {
                        var places = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Place];
                        var found = false;
                        for p in places
                        {
                            if p.id == allP.id
                            {
                                found = true;
                            }
                        }
                        if(!found)
                        {
                            places.append(allP);
                            defaults.set(NSKeyedArchiver.archivedData(withRootObject: places), forKey: "places");
                        }
                    }
                    else
                    {
                        var places = [Place]();
                        places.append(allP);
                        defaults.set(NSKeyedArchiver.archivedData(withRootObject: places), forKey: "places");
                    }
                    defaults.synchronize();
                }
            }
        }
        //print(locations.last?.description);
    }
    
    

}
