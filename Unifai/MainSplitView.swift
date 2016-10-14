//
//  MainSplitView.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 27/05/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation
import UIKit

class MainSplitView : UISplitViewController , UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        self.delegate = self
        self.view.backgroundColor = currentTheme.backgroundColor
    }
    
    var selectedMessage : Message?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toThread"{
            let destination = segue.destination as! ThreadViewController
            destination.threadDelegate = ((self.childViewControllers[0] as! UINavigationController).childViewControllers[0] as! FeedViewController)
            destination.loadData(selectedMessage!.threadID!)
        }
        else if segue.identifier == "toProfile"{
            let destination = segue.destination as! ServiceProfileViewcontroller
            destination.loadData(selectedMessage!.service)
        }
    }
    
    func splitViewController(_ svc: UISplitViewController, shouldHide vc: UIViewController, in orientation: UIInterfaceOrientation) -> Bool {
        return false
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
}
