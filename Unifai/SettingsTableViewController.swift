//
//  SettingsTableViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 03/06/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
import RFAboutView_Swift

class SettingsTableViewController: UITableViewController , SettingsListDelegate {

    @IBOutlet weak var switchDarkTheme: UISwitch!
    @IBOutlet weak var switchTextOnFeed: UISwitch!
    @IBOutlet weak var txtTextSizePreview: UILabel!
    
    @IBOutlet weak var txtStartingPagePreview: UILabel!
    @IBOutlet weak var txtCacheSize: UILabel!
    let textSizeItems = ["Small" , "Medium" , "Large"]
    let startingPageItems = ["Feed" , "Dashboard" , "Action","Scheduling" , "Profile"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barStyle = .Default
        self.tabBarController?.tabBar.barStyle = .Default
//        
//        txtTextSizePreview.text = textSizeItems[ Settings.textSize ]
//        txtCardSizePreview.text = textSizeItems[ Settings.cardSize ]
        switchTextOnFeed.on = Settings.onlyTextOnFeed
        switchDarkTheme.on = Settings.darkTheme
        
        txtCacheSize.text = String(NSFileManager.defaultManager().folderSizeAtPath(Cache.cacheFolder.path!)/Int64(1024)) + "KB"
    }

    @IBAction func changeTheme(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(switchDarkTheme.on, forKey: "darkTheme")
        Settings.darkTheme = switchDarkTheme.on
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func deleteCache() {
        do {
            let paths = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(Cache.cacheFolder.path!)
            for path in paths
            {
                try NSFileManager.defaultManager().removeItemAtPath("\(Cache.cacheFolder.path!)/\(path)")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var items : [String] = []
        let id = tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
        var selected = 0
        
        if id == "logout" {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
            NSUserDefaults.standardUserDefaults().synchronize()
            deleteCache()
            self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        else if id == "deleteCache" {
            deleteCache()
            self.txtCacheSize.text = "0KB"
            return
        }
        else if id == "about" {
            let aboutNav = UINavigationController()
            
            // Initialise the RFAboutView:
            
            let aboutView = RFAboutViewController(copyrightHolderName: "Unifai", contactEmail: "unifai@outlook.com", contactEmailTitle: "Contact us", websiteURL: NSURL(string: "http://unifai.xyz"), websiteURLTitle: "Our Website")
            
            
            aboutView.headerBackgroundColor = Constants.appBrandColor
            aboutView.headerTextColor = .whiteColor()
            aboutView.blurStyle = .Dark
            aboutView.headerBackgroundImage = UIImage(named: "unifai")
            
            // Add the aboutView to the NavigationController:
            aboutNav.setViewControllers([aboutView], animated: false)
            
            // Present the navigation controller:
            self.presentViewController(aboutNav, animated: true, completion: nil)
            return
        }
        else if(id == "textSize"){
            items = textSizeItems
            selected = Settings.textSize
        }
        else if(id == "startingPage"){
            items = startingPageItems
            selected = Settings.startingPage
        }
//        else if(id == "cardSize"){
//            items = textSizeItems
//            selected = Settings.cardSize
//        }
        
        let selection = SettingsListTableViewController()
        selection.items = items
        selection.delegate = self
        selection.id = id!
        selection.selected = selected
        self.navigationController?.pushViewController(selection, animated: true)
    }
    
    func setSelection(id: String, index: Int , label:String) {
        if(id == "textSize"){
            self.txtTextSizePreview.text = label
            NSUserDefaults.standardUserDefaults().setInteger(index, forKey: "textSize")
            Settings.textSize = index
        }
        else if(id == "startingPage"){
            self.txtStartingPagePreview.text = label
            NSUserDefaults.standardUserDefaults().setInteger(index, forKey: "startingPage")
            Settings.startingPage = index
        }
//        else if(id == "cardSize"){
//            self.txtCardSizePreview.text = label
//            NSUserDefaults.standardUserDefaults().setInteger(index, forKey: "cardSize")
//            Settings.cardSize = index
//        }
        
    }
    
    @IBAction func onSwitchTextOnFeed(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(switchTextOnFeed.on, forKey: "onlyTextOnFeed")
        Settings.onlyTextOnFeed = switchTextOnFeed.on
    }
}
