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
    
    
    @IBOutlet weak var headerBackground: UIView!
    @IBOutlet weak var headerImage: UIImageView!
    var messages : [Message] = []
    var pinnedMessage : Message?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    let activtyControl = UIActivityIndicatorView(activityIndicatorStyle: .White)
    
    override func viewDidLoad() {
        self.tableView!.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")

        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .None
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        
        self.tableView.addSubview(self.refreshControl)
        //loadData()
        
        navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.backIndicatorImage = UIImage()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 220))
        header.userInteractionEnabled = false
        let pinnedText = UILabel()
        pinnedText.textColor = currentTheme.foregroundColor
        pinnedText.text = "Pinned message"
        header.addSubview(pinnedText)
        pinnedText.snp_makeConstraints(closure: { make in
                make.bottomMargin.leftMargin.rightMargin.equalTo(0)
                make.height.equalTo(30)
        })
        pinnedText.backgroundColor = currentTheme.secondaryBackgroundColor
        pinnedText.textAlignment = .Center
        pinnedText.font = pinnedText.font.fontWithSize(14)
        
        headerBackground.addSubview(activtyControl)
        activtyControl.snp_makeConstraints(closure: { make in
                make.center.equalTo(headerBackground)
        })
        activtyControl.startAnimating()
        self.tableView.alpha = 0
        
//
//        let pinnedMessageHolder = UI()
//        pinnedMessageHolder.backgroundColor = UIColor.whiteColor()
//        header.addSubview(pinnedMessageHolder)
//        pinnedMessageHolder.snp_makeConstraints(closure:  { make in
//                make.bottomMargin.equalTo(-10)
//                make.topMargin.equalTo(200)
//                make.leftMargin.equalTo(20)
//                make.rightMargin.equalTo(-20)
//                make.height.equalTo(110)
//            })
//        pinnedMessageHolder.layer.shadowColor = UIColor.blackColor().CGColor
//        pinnedMessageHolder.layer.shadowOffset = CGSizeZero
//        pinnedMessageHolder.layer.shadowRadius = 5
//        pinnedMessageHolder.layer.shadowOpacity = 0.1
//        
//        pinnedMessageHolder.addSubview(messageControl)
//        messageControl.snp_makeConstraints(closure: {make in
//         make.leftMargin.topMargin.rightMargin.bottomMargin.equalTo(0)
//        })
        
        self.view.backgroundColor = currentTheme.backgroundColor
        
        self.tableView.tableHeaderView = header
        
        
        
        if( traitCollection.forceTouchCapability == .Available){
            
            registerForPreviewingWithDelegate(self, sourceView: view)
            
        }
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        self.headerImage.image = UIImage(named: (service?.username)!)
        
        headerImage.layer.shadowColor = UIColor.blackColor().CGColor
        headerImage.layer.shadowOffset = CGSizeZero
        headerImage.layer.shadowOpacity = 0.35
        headerImage.layer.shadowRadius = 15
        self.headerBackground.backgroundColor = service?.color
        
        self.navigationController?.navigationBar.barTintColor = service!.color

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
    
    var service : Service?
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func loadData(service:Service?){
        guard service != nil else{ return }
        self.service = service
        self.navigationItem.title = service?.name
        
        Unifai.getProfile(service!.username , completion: { pinnedMessage , threadMessages in
            self.messages = threadMessages
            self.pinnedMessage = pinnedMessage
            self.tableView?.reloadData()
            self.refreshControl.endRefreshing()
            self.activtyControl.stopAnimating()
            UIView.animateWithDuration(0.5, animations: {
                self.tableView.alpha = 1
            })
            
            
        })
    }
    @IBAction func doneTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        loadData(self.service)
    }
    
    var selectedRow = 0
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        
        guard let detailVC = UIStoryboard(name: "Thread", bundle: nil).instantiateViewControllerWithIdentifier("ThreadViewController") as? ThreadViewController else { return }
        
        detailVC.loadData(messages[selectedRow - 1].threadID!)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.selectionStyle = .None
        cell.setMessage(indexPath.row == 0 ? pinnedMessage! : messages[indexPath.row - 1])
        cell.hideTime = indexPath.row == 0
        if indexPath.row == 0 {
            cell.backgroundColor = currentTheme.secondaryBackgroundColor
        }
        cell.parentViewController = self
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count + (pinnedMessage == nil ? 0 : 1)
    }
}
