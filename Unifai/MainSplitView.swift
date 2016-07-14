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
    }
    
    var selectedMessage : Message?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toThread"{
            let destination = segue.destinationViewController as! ThreadViewController
            destination.loadData(selectedMessage!.threadID!)
        }
        else if segue.identifier == "toProfile"{
            let destination = segue.destinationViewController as! ServiceProfileViewcontroller
            destination.loadData(selectedMessage!.service)
        }
    }
    
    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return false
    }
    
    
}
