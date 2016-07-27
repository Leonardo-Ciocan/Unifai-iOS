import UIKit
import AlertOnboarding
import GSImageViewerController
import DGElasticPullToRefresh
extension UIScrollView {
    func dg_stopScrollingAnimation() {}
}
class FeedViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UIViewControllerPreviewingDelegate , MessageCreatorDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var creatorAssistant: CreatorAssistant!
    var messages : [Message] = []
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    var mainSplitView : MainSplitView {
        return self.splitViewController as! MainSplitView
    }
    let doneButton = UIBarButtonItem()
    var creator : MessageCreator?
    
    @IBOutlet weak var btnCatalog: UIBarButtonItem!
    @IBOutlet weak var assistantBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        //Theme setup
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        

        doneButton.action = #selector(doneClicked)
        doneButton.title = "Done"
        doneButton.style = .Done
        
        self.tableView!.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .None
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        guard NSUserDefaults.standardUserDefaults().stringForKey("token") != nil else{return}
        
        self.tabBarController?.title = "Feed"
        //self.tableView.addSubview(self.refreshControl)
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.whiteColor()
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self!.loadData()
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(Constants.appBrandColor)
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
        Core.populateAll(withCallback: {
            Cache.getFeed({ messages in
                self.messages = messages
                self.tableView.reloadData()
                self.loadData()
            })
        })
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
        self.creator = MessageCreator(frame: CGRect(x: 0, y: 0, width: self.view.frame.width , height: 110))
        creator!.assistant = creatorAssistant
        creator!.parentViewController = self
        creator!.creatorDelegate = self
        creator!.backgroundColor = UIColor.whiteColor()
        tableView.tableHeaderView = creator
        
//        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 66, height: 33))
//        imageView.contentMode = .ScaleAspectFit
//
//        let image = UIImage(named: "ai")
//        imageView.image = image?.imageWithRenderingMode(.AlwaysTemplate)
//        //imageView.image = image
//        imageView.tintColor = currentTheme.secondaryForegroundColor
//        
//        
//        
//        navigationItem.titleView = imageView

        
//        let txtTile = UILabel(frame:CGRect(x:0,y:0,width:150,height:33))
//        txtTile.text = "UNIFAI"
//        txtTile.textAlignment = .Center
//        txtTile.textColor = currentTheme.foregroundColor
//        txtTile.font = UIFont(name: "AmericanTypewriter", size: 18)
//
//        navigationItem.titleView = txtTile
        
        
        self.navigationItem.title = "Feed"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)! ]
        
        if( traitCollection.forceTouchCapability == .Available){
            
            registerForPreviewingWithDelegate(self, sourceView: view)
        }
        
        registerForKeyboardNotifications()
    }
    
    func didSelectService(service: Service?) {
        UIView.animateWithDuration(1, animations: {
            },completion: { _ in
                self.navigationController?.navigationBar.barStyle = service == nil ? currentTheme.barStyle : .Black
                self.navigationController?.navigationBar.barTintColor = service == nil ? nil : service!.color
                self.navigationController?.navigationBar.tintColor = service == nil ? currentTheme.foregroundColor : UIColor.whiteColor()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        //Theme setup
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        self.navigationController?.navigationBar.barTintColor = nil
        self.navigationController?.navigationBar.tintColor = currentTheme.foregroundColor
        self.navigationController?.navigationBar.translucent = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
    
    func getServicesAndUser(callback: ([Service]) -> () ){
        if Core.Services.count > 0 {
            callback(Core.Services)
            return
        }
        Unifai.getServices({ services in
            Unifai.getUserInfo({username , email in
                Core.Username = username
                callback(services)
            })
        })
    }
    
    func sendMessage(message: String) {
            Unifai.sendMessage(message, completion: { success in
                    self.loadData()
                })
    }
    
    func sendMessage(message: String, imageData: NSData) {
            Unifai.sendMessage(message , imageData: imageData, completion: { success in
                self.loadData()
            })
    }
    
    func showValidationMessage() {
        let alert = UIAlertController(title: "Can't send this message", message: "You need to mention a service , for example @skyscanner", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                print("default")
                
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = currentTheme.statusBarStyle
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRowAtPoint(location) else { return nil }
        
        guard let cell = tableView?.cellForRowAtIndexPath(indexPath) else { return nil }
        
        guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier("ThreadViewController") as? ThreadViewController else { return nil }
        
        detailVC.loadData(messages[indexPath.row].threadID!)
        
        detailVC.preferredContentSize = CGSize(width: 0.0, height: 300)
        
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
            let msg = messages.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
            Unifai.deleteThread(msg.threadID!, completion: nil)
        }
    }
    
    
    func loadData(){
        //this is a feed view
        Unifai.getFeed({ threadMessages in
            self.messages = threadMessages
            self.tableView?.reloadData()
            self.refreshControl.endRefreshing()
            
        })
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        loadData()
    }
    
    
    
    var selectedRow = 0
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        self.mainSplitView.selectedMessage = messages[indexPath.row]
        self.splitViewController!.performSegueWithIdentifier("toThread", sender: self)
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.selectionStyle = .None
        cell.shouldShowText = !Settings.onlyTextOnFeed
        cell.setMessage(messages[indexPath.row] , shouldShowThreadCount: true)
        cell.imgLogo.addTarget(self, action: #selector(imageTapped), forControlEvents: .TouchUpInside)

        cell.accessoryView = cell.imgLogo as UIView
        cell.imgLogo.contentMode = .ScaleAspectFit
        cell.imgLogo.userInteractionEnabled = true
        cell.imgLogo.tag = indexPath.row
        
        if let imgView = cell.imgView {
            let singleTap = UITapGestureRecognizer(target: self, action:#selector(payloadImageTapped))
            singleTap.numberOfTapsRequired = 1
            imgView.userInteractionEnabled = true
            imgView.addGestureRecognizer(singleTap)
        }
        
        return cell
    }
    
    func payloadImageTapped(senderA:UITapGestureRecognizer){
        let sender = senderA.view as! UIImageView
        let imageInfo      = GSImageInfo(image: sender.image!, imageMode: .AspectFit, imageHD: nil)
        let transitionInfo = GSTransitionInfo(fromView: sender)
        let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        self.presentViewController(imageViewer, animated: true, completion: nil)
    }
    
    func imageTapped(sender: UIButton) {
        selectedRow = sender.tag
        self.mainSplitView.selectedMessage = messages[selectedRow]
        self.splitViewController!.performSegueWithIdentifier("toProfile", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var barItem : UIBarButtonItem?
    @IBAction func toCatalog(sender: AnyObject) {
        self.performSegueWithIdentifier("toCatalog", sender: self)
//
//        barItem = sender as! UIBarButtonItem
//        spinner.startAnimating()
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
//        Unifai.getCatalog({ catalog in
//                Core.Catalog = catalog
//                self.navigationItem.rightBarButtonItem = self.barItem
//        })
    }
    
    
    
    func doneClicked(){
        self.didSelectService(nil)
        creator?.txtMessage.resignFirstResponder()
    }
    
    func didStartWriting() {
        self.navigationItem.leftBarButtonItem = doneButton
    }
    
    func didFinishWirting() {
        self.navigationItem.leftBarButtonItem = nil
    }
    
    func chooseAction() {
        let menu = UIAlertController(title: "Run an action", message: "", preferredStyle: .ActionSheet)
        
        Unifai.getActions({ actions in
            for action in actions{
                let item = UIAlertAction(title: action.name, style: .Default, handler: { (alert:UIAlertAction!) -> Void in
                    if let selected = actions.filter({$0.name == alert.title}).first{
                        self.sendMessage(selected.message)
                    }
                })
                menu.addAction(item)
            }
            menu.addAction(UIAlertAction(title: "Cancel" , style: .Cancel , handler: nil))
            self.presentViewController(menu, animated: true, completion: nil)
        })
    }

    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        var info : NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        var contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        assistantBottomConstraint.constant = (keyboardSize?.height)! - (tabBarController?.tabBar.frame.height)!
    }
    
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        assistantBottomConstraint.constant = 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.modalPresentationStyle = .Popover
        segue.destinationViewController.popoverPresentationController!.barButtonItem = btnCatalog
        
        
        segue.destinationViewController.preferredContentSize = CGSizeMake(400,550)
    }

    
}
