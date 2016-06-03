//
//  SettingsListTableViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 03/06/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

protocol SettingsListDelegate {
    func setSelection(id:String , index:Int, label:String)
}

class SettingsListTableViewController: UITableViewController {

    @IBOutlet var tb: UITableView!
    var delegate : SettingsListDelegate?
    var items = []
    var id = ""
    var selected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
       
        
        self.tableView = UITableView(frame: self.view.frame, style: .Grouped)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)

        cell.textLabel?.text = items[indexPath.row] as! String
        cell.accessoryType = indexPath.row == selected ? .Checkmark : .None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.setSelection(id, index: indexPath.row, label: self.items[indexPath.row] as! String)
        self.navigationController?.popViewControllerAnimated(true)
    }

  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
