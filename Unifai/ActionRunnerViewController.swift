//
//  ActionRunnerViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 01/08/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class ActionRunnerViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {

    @IBOutlet weak var headerBackground: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgLogo: UIImageView!
    
    var messages : [Message] = []
    var resultMessage : Message?
    var action : Action?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        imgLogo.layer.shadowColor = UIColor.blackColor().CGColor
        imgLogo.layer.shadowOffset = CGSizeZero
        imgLogo.layer.shadowOpacity = 0.35
        imgLogo.layer.shadowRadius = 15
        
        tableView.registerNib(UINib(nibName: "MessageCell",bundle: nil), forCellReuseIdentifier: "MessageCell")
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = currentTheme.backgroundColor
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Discard", style: .Plain, target: self, action: #selector(discard))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Keep", style: .Plain, target: self, action: #selector(keep))
        
        let service = TextUtils.extractService(action!.message)
        imgLogo.image = UIImage(named: (service?.username)!)
        self.headerBackground.backgroundColor = service?.color
        self.navigationController?.navigationBar.barTintColor = service?.color
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.view.backgroundColor = currentTheme.backgroundColor
        
        let message = Message(body: action!.message, type: .Text, payload: nil)
        messages = [message]
        Unifai.runAction(action!, completion: { msg in
            self.resultMessage = msg
            self.messages.append(msg)
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.selectionStyle = .None
        cell.setMessage(messages[indexPath.row] , shouldShowThreadCount: false)
        cell.hideTime = true
        cell.parentViewController = self
        return cell
    }
    
    
    @IBAction func keep(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func discard(sender: AnyObject) {
        if resultMessage != nil {
            Unifai.deleteThread((resultMessage?.threadID!)!, completion: nil)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadAction(action:Action) {
        self.action = action
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
