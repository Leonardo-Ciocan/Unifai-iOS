//
//  SchedulesViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 29/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class SchedulesViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var schedules : [Schedule] = [
        
    ]
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        self.tableView!.registerNib(UINib(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .None
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        guard NSUserDefaults.standardUserDefaults().stringForKey("token") != nil else{return}
        
        self.tableView.addSubview(self.refreshControl)
        
        
        
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 33, height: 33))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "logo")
        imageView.image = image
        navigationItem.titleView = imageView
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorInset = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 118
    }
    
    @IBAction func addNewSchedule(sender: AnyObject) {
        self.showViewController(NewScheduleController(), sender: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        loadData()
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
//            let msg = messages.removeAtIndex(indexPath.row)
//            self.tableView.reloadData()
//            Unifai.deleteThread(msg.threadID!, completion: nil)
        }
    }
    
    
    func loadData(){
        Unifai.getSchedules({ schedules in
            self.schedules = schedules
            self.tableView?.reloadData()
            self.refreshControl.endRefreshing()
        })
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        loadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell") as! ScheduleCell
        cell.selectionStyle = .None
        cell.loadData(schedules[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules.count
    }
    

}
