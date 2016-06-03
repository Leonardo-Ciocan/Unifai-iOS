//
//  SettingsTableViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 03/06/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController , SettingsListDelegate {

    @IBOutlet weak var switchTextOnFeed: UISwitch!
    @IBOutlet weak var txtTextSizePreview: UILabel!
    
    @IBOutlet weak var txtStartingPagePreview: UILabel!
    let textSizeItems = ["Small" , "Medium" , "Large"]
    let startingPageItems = ["Feed" , "Dashboard" , "Action","Scheduling" , "Profile"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        txtTextSizePreview.text = textSizeItems[ NSUserDefaults.standardUserDefaults().integerForKey("textSize")]
        switchTextOnFeed.on = NSUserDefaults.standardUserDefaults().boolForKey("onlyTextOnFeed")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var items : [String] = []
        let id = tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
        var selected = 0
        
        if(id == "textSize"){
            items = textSizeItems
            selected = NSUserDefaults.standardUserDefaults().integerForKey("textSize")
        }
        else if(id == "startingPage"){
            items = startingPageItems
            selected = NSUserDefaults.standardUserDefaults().integerForKey("startingPage")
        }
        
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
        }
        else if(id == "startingPage"){
            self.txtStartingPagePreview.text = label
            NSUserDefaults.standardUserDefaults().setInteger(index, forKey: "startingPage")
        }
    }
    
    @IBAction func onSwitchTextOnFeed(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(switchTextOnFeed.on, forKey: "onlyTextOnFeed")
    }
}
