//
//  ServiceProfileViewcontroller.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 27/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class ServiceProfileViewcontroller: UIViewController , UITableViewDelegate , UITableViewDataSource ,UIViewControllerPreviewingDelegate{
    @IBOutlet weak var tableView: UITableView!
    
    
    var messages : [Message] = []
    var header : UIImageView = UIImageView()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    
    
    override func viewDidLoad() {
        self.tableView!.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")

        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .None
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        
        self.tabBarController?.title = "Feed"
        self.tableView.addSubview(self.refreshControl)
        //loadData()
        
        self.header.frame = CGRect(x:0,y:0,width:self.tableView.frame.width,height:130)
        self.header.contentMode = .ScaleAspectFill
        self.tableView.tableHeaderView = self.header
        
        if( traitCollection.forceTouchCapability == .Available){
            
            registerForPreviewingWithDelegate(self, sourceView: view)
            
        }
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRowAtPoint(location) else { return nil }
        
        guard let cell = tableView?.cellForRowAtIndexPath(indexPath) else { return nil }
        
        guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier("ThreadViewController") as? ThreadViewController else { return nil }
        
        detailVC.loadData(messages[indexPath.row].threadID!)
        
        detailVC.preferredContentSize = CGSize(width: 0.0, height: 600)
        
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        
        showViewController(viewControllerToCommit, sender: self)
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            messages.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    var service : Service?
    
    func loadData(service:Service?){
        guard service != nil else{return}
        
        self.header.image = UIImage(named: (service?.username)! + "-banner")
        self.navigationItem.title = service?.name
        Unifai.getProfile(service!.username , completion: { threadMessages in
            self.messages = threadMessages
            self.tableView?.reloadData()
            self.refreshControl.endRefreshing()
            
        })
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        loadData(self.service)
    }
    
    var selectedRow = 0
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        self.performSegueWithIdentifier("toThread", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toThread"{
            let destination = segue.destinationViewController as! ThreadViewController
            destination.loadData(messages[selectedRow].threadID!)
        }
        else if segue.identifier == "toCompose"{
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.selectionStyle = .None
        cell.setMessage(messages[indexPath.row])
        cell.imgLogo.addTarget(self, action: #selector(imageTapped), forControlEvents: .TouchUpInside)
        
        cell.accessoryView = cell.imgLogo as UIView
        cell.imgLogo.contentMode = .ScaleAspectFit
        cell.imgLogo.userInteractionEnabled = true
        return cell
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("toProfile", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
}
