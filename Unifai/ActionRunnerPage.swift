//
//  ActionRunnerPage.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 14/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class ActionRunnerPage: UIView , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var btnKeep: UIButton!
    @IBOutlet weak var btnDiscard: UIButton!
    
    var btnKeepHandler : (()->())?
    var btnDiscardHandler : (()->())?
    var message : Message?
    
    @IBOutlet weak var colorView: UIView!
    var messages : [Message] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "ActionRunnerPage", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        
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
        
        self.addSubview(view);
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.selectionStyle = .None
        cell.setMessage(messages[indexPath.row] , shouldShowThreadCount: false)
        cell.hideTime = true
        return cell
    }

    
    @IBAction func keep(sender: AnyObject) {
        self.btnKeepHandler!()
    }
    
    
    @IBAction func discard(sender: AnyObject) {
        self.btnDiscardHandler!()
    }
}
