//
//  TabBarViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 03/06/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.selectedIndex = NSUserDefaults.standardUserDefaults().integerForKey("startingPage")
        self.tabBar.barStyle = currentTheme.barStyle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}
