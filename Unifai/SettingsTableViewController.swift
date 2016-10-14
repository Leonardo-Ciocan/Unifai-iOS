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

        self.navigationController?.navigationBar.barStyle = .default
        self.tabBarController?.tabBar.barStyle = .default
//        
//        txtTextSizePreview.text = textSizeItems[ Settings.textSize ]
//        txtCardSizePreview.text = textSizeItems[ Settings.cardSize ]
        switchTextOnFeed.isOn = Settings.onlyTextOnFeed
        switchDarkTheme.isOn = Settings.darkTheme
        
        txtCacheSize.text = String(FileManager.default.folderSizeAtPath(Cache.cacheFolder.path!)/Int64(1024)) + "KB"
    }

    @IBAction func changeTheme(_ sender: AnyObject) {
        UserDefaults.standard.set(switchDarkTheme.isOn, forKey: "darkTheme")
        Settings.darkTheme = switchDarkTheme.isOn
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func deleteCache() {
        do {
            let paths = try FileManager.default.contentsOfDirectory(atPath: Cache.cacheFolder!.path)
            for path in paths
            {
                try FileManager.default.removeItem(atPath: "\(Cache.cacheFolder?.path)/\(path)")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var items : [String] = []
        let id = tableView.cellForRow(at: indexPath)?.reuseIdentifier
        var selected = 0
        
        if id == "logout" {
            UserDefaults.standard.removeObject(forKey: "token")
            UserDefaults.standard.synchronize()
            deleteCache()
            self.tabBarController?.dismiss(animated: true, completion: nil)
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
            
            let aboutView = RFAboutViewController(copyrightHolderName: "Unifai", contactEmail: "unifai@outlook.com", contactEmailTitle: "Contact us", websiteURL: URL(string: "http://unifai.xyz"), websiteURLTitle: "Our Website")
            
            
            aboutView.headerBackgroundColor = Constants.appBrandColor
            aboutView.headerTextColor = .white()
            aboutView.blurStyle = .dark
            aboutView.headerBackgroundImage = UIImage(named: "unifai")
            
            // Add the aboutView to the NavigationController:
            aboutNav.setViewControllers([aboutView], animated: false)
            
            // Present the navigation controller:
            self.present(aboutNav, animated: true, completion: nil)
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
    
    func setSelection(_ id: String, index: Int , label:String) {
        if(id == "textSize"){
            self.txtTextSizePreview.text = label
            UserDefaults.standard.set(index, forKey: "textSize")
            Settings.textSize = index
        }
        else if(id == "startingPage"){
            self.txtStartingPagePreview.text = label
            UserDefaults.standard.set(index, forKey: "startingPage")
            Settings.startingPage = index
        }
//        else if(id == "cardSize"){
//            self.txtCardSizePreview.text = label
//            NSUserDefaults.standardUserDefaults().setInteger(index, forKey: "cardSize")
//            Settings.cardSize = index
//        }
        
    }
    
    @IBAction func onSwitchTextOnFeed(_ sender: AnyObject) {
        UserDefaults.standard.set(switchTextOnFeed.isOn, forKey: "onlyTextOnFeed")
        Settings.onlyTextOnFeed = switchTextOnFeed.isOn
    }
}
