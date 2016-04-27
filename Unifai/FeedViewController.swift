//
//  FeedViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 26/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var messages : [Message] = []
    
    override func viewDidLoad() {
        self.tableView!.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .None
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        guard NSUserDefaults.standardUserDefaults().stringForKey("token") != nil else{return}
        
        //this is a feed view
        Unifai.getServices({ services in
            Core.Services = services
            Unifai.getFeed({ threadMessages in
                self.messages = threadMessages
                self.tableView?.reloadData()
            })
        })
        self.tabBarController?.title = "Feed"
    }
    
    
    var selectedRow = 0
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        self.performSegueWithIdentifier("toThread", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! ThreadViewController
        destination.loadData(messages[selectedRow].threadID!)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.selectionStyle = .None
        cell.setMessage(messages[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
}
