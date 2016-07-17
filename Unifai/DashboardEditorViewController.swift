//
//  DashboardEditorViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 29/05/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class DashboardEditorViewController: UIViewController , UITableViewDataSource , UITableViewDelegate{

    @IBOutlet
    var tableView: UITableView!
    
    var items : [String] = []
    var header : DashboardEditorHeader?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.editing = true
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()
        header = DashboardEditorHeader(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        header!.btnCreate.addTarget(self, action: #selector(create), forControlEvents: .TouchUpInside)
        self.tableView.tableHeaderView = header
        loadData()
    }
    
    func create() {
        self.items.append((header?.txtMessage.text)!)
        self.tableView.reloadData()
        header?.txtMessage.text = ""
    }
    
    func loadData(){
        Unifai.getDashboardItems({ items in
            self.items = items
            self.tableView.reloadData()
        })
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let temp = items[sourceIndexPath.row]
        items[sourceIndexPath.row] = items[destinationIndexPath.row]
        items[destinationIndexPath.row] = temp
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        cell.textLabel?.textColor = currentTheme.foregroundColor
        cell.backgroundColor = currentTheme.backgroundColor
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    @IBAction func newItem(sender: AnyObject) {
        let alert = UIAlertController(title: "New item", message: "Enter a query to be answered", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "@weather What's the weather like in London?"
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel , handler: nil))
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default , handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.items.append(textField.text!)
            self.tableView.reloadData()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            items.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        Unifai.setDashboardItems(self.items, completion: { s in
                self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}