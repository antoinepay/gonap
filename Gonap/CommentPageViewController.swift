//
//  CommentPageViewController.swift
//  Gonap
//
//  Created by Antoine Payan on 20/04/2017.
//  Copyright © 2017 velocifraptor. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class CommentPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    let pages = ["explanations", "zoneSelection"]
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        if self.revealViewController() != nil {
            menuButton.FAIcon=FAType.FABars;
            menuButton.image=nil;
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        self.dataSource = self
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "explanations")
        setViewControllers([vc!], // Has to be a single item array, unless you're doing double sided stuff I believe
            direction: .forward,
            animated: true,
            completion: nil)
        self.view.backgroundColor=UIColor.lightGray;
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let identifier = viewController.restorationIdentifier {
            if let index = pages.index(of: identifier) {
                if index > 0 {
                    return self.storyboard?.instantiateViewController(withIdentifier: pages[index-1])
                }
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let identifier = viewController.restorationIdentifier {
            if let index = pages.index(of: identifier) {
                if index < pages.count - 1 {
                    return self.storyboard?.instantiateViewController(withIdentifier: pages[index+1])
                }
            }
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if let identifier = viewControllers?.first?.restorationIdentifier {
            if let index = pages.index(of: identifier) {
                return index
            }
        }
        return 0
    }

}
