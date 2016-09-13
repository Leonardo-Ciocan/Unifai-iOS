import UIKit
import AlertOnboarding
import GSImageViewerController
import DGElasticPullToRefresh

extension UIScrollView {
    func dg_stopScrollingAnimation() {}
}


//Table view methods
extension FeedViewController {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        self.mainSplitView.selectedMessage = messages[indexPath.row]
        self.navigationController!.navigationBar.hidden = false
        self.splitViewController!.performSegueWithIdentifier("toThread", sender: self)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.selectionStyle = .None
        cell.shouldShowText = !Settings.onlyTextOnFeed
        cell.setMessage(messages[indexPath.row] , shouldShowThreadCount: true)
        cell.delegate = self
        cell.accessoryView = cell.imgLogo as UIView
        cell.imgLogo.contentMode = .ScaleAspectFit
        cell.imgLogo.userInteractionEnabled = true
        cell.parentViewController = self
        cell.txtBody.userInteractionEnabled = false
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            let msg = messages.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
            Unifai.deleteThread(msg.threadID!, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}

//Cell creator delegate
extension FeedViewController : MessageCreatorDelegate {
    func shouldThemeHostWithColor(color: UIColor) {
        UIView.animateWithDuration(1, animations: {
            },completion: { _ in
                self.navigationController?.navigationBar.barStyle =  .Black
                self.navigationController?.navigationBar.barTintColor =  color
                self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
                self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        })
    }
    
    func shouldRemoveThemeFromHost() {
        UIView.animateWithDuration(1, animations: {
            },completion: { _ in
                self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
                self.navigationController?.navigationBar.barTintColor = nil
                self.navigationController?.navigationBar.tintColor = currentTheme.foregroundColor
                self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)!, NSForegroundColorAttributeName: currentTheme.foregroundColor]
        })
    }
    
    func didStartWriting() {
    }
    
    func didFinishWirting() {
    }
    
    func shouldAppendMessage(message: Message) {
        guard message.service != nil else { return }
        offset += 1
        self.messages.insert(message, atIndex: 0)
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow:0,inSection:0)], withRowAnimation: .Automatic)
        self.tableView.endUpdates()
    }
}

//Cell delegate
extension FeedViewController {
    func didFinishAuthenticationFromMessage(message: Message?) {
        guard let message = message ,
            let threadID = message.threadID
            else { return }
        Unifai.getThread(threadID, completion: { threadMessages in
            guard threadMessages.count > 1 else { return }
            let messageToResend = threadMessages[threadMessages.count - 2]
            guard messageToResend.isFromUser else { return }
            Unifai.sendMessage(messageToResend.body, thread: threadID, completion: { answer in
                guard let indexToReplace = self.messages.indexOf({ $0.id == message.id }) else { return }
                self.messages[indexToReplace] = answer
                self.tableView.reloadData()
            })
        })
    }
    
    func shouldSendMessageWithText(text: String, sourceRect: CGRect, sourceView: UIView) {
        let runner = ActionRunnerViewController()
        runner.loadAction(Action(message: text, name: ""))
        
        let rootVC = UINavigationController(rootViewController: runner)
        rootVC.modalPresentationStyle = .Popover
        rootVC.popoverPresentationController!.sourceView = sourceView
        rootVC.popoverPresentationController!.sourceRect = sourceRect
        rootVC.preferredContentSize = CGSizeMake(350,500)
        self.presentViewController(rootVC, animated: true, completion: nil)
    }
}

class FeedViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , MessageCellDelegate , ThreadVCDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCatalog: UIBarButtonItem!
    @IBOutlet weak var assistantBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var creatorAssistant: CreatorAssistant!
    
    var messages : [Message] = []
    var selectedRow = 0
    var mainSplitView : MainSplitView {
        return self.splitViewController as! MainSplitView
    }
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var reloadPrompt: UIView!
    let loadMoreSpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let loadMoreText = UILabel()
    var didReachEndOfFeed = false
    
    @IBOutlet
    var creator : MessageCreator?
    
    var offset = 0
    let limit = 10
    @IBOutlet weak var creatorShadow: UIView!
    
    override func viewDidLoad() {
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        
        self.tableView!.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .None
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        guard NSUserDefaults.standardUserDefaults().stringForKey("token") != nil else{return}
        
        self.tabBarController?.title = "Feed"
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.whiteColor()
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.offset = 0
            self?.didReachEndOfFeed = false
            self?.loadMoreText.text = "Scroll to load more"
            self!.loadData()
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(Constants.appBrandColor)
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
        self.loadData()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
        creator!.assistant = creatorAssistant
        creator!.parentViewController = self
        creator!.creatorDelegate = self
        creator!.backgroundColor = UIColor.clearColor()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width , height: 110))
        
        let loadMoreFooter = UIView(frame: CGRect(x:0,y:0, width: self.view.frame.width,height: 55))
        loadMoreText.text = "Scroll to load more"
        loadMoreText.textColor = UIColor.grayColor()
        loadMoreSpinner.hidesWhenStopped = true
        loadMoreText.hidden = true
        
        loadMoreFooter.addSubview(loadMoreText)
        loadMoreFooter.addSubview(loadMoreSpinner)
        
        loadMoreText.snp_makeConstraints(closure: { make in
            make.center.equalTo(loadMoreFooter)
        })
        
        loadMoreSpinner.snp_makeConstraints(closure: { make in
            make.center.equalTo(loadMoreFooter)
        })
        
        tableView.tableFooterView = loadMoreFooter
        
        
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)!, NSForegroundColorAttributeName: currentTheme.foregroundColor]
        
        registerForKeyboardNotifications()
        self.navigationController?.navigationBar.tintColor = currentTheme.foregroundColor
        
        self.navigationController!.navigationBar.hidden = true
        
        reloadPrompt.layer.shadowColor = UIColor.blackColor().CGColor
        reloadPrompt.layer.shadowOffset = CGSizeZero
        reloadPrompt.layer.shadowOpacity = 0.11
        reloadPrompt.layer.shadowRadius = 10
        reloadPrompt.layer.borderWidth = 1
        reloadPrompt.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.2).CGColor
        
        creatorShadow.layer.shadowPath = CGPathCreateWithRect(creatorShadow.bounds, nil)
        creatorShadow.layer.shadowColor = UIColor.blackColor().CGColor
        creatorShadow.layer.shadowOffset = CGSizeZero
        creatorShadow.layer.shadowOpacity = 0.11
        creatorShadow.layer.shadowRadius = 10
        creatorShadow.layer.borderWidth = 0
        creatorShadow.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.2).CGColor
        
        visualEffectView.effect = UIBlurEffect(style:currentTheme.visualEffectStyle)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
    }
    
    func feedShouldUpdate(message message: Message, forThread threadID: String) {
        guard let indexToReplace = self.messages.indexOf({ $0.threadID == threadID }) else { return }
        self.messages[indexToReplace] = message
        self.tableView.reloadData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
    
    func loadData() {
        Unifai.getFeed(fromOffset: offset, andAmount: limit, completion: { messages in
            if messages.count == 0 {
                self.didReachEndOfFeed = true
                self.loadMoreText.hidden = false
                self.loadMoreText.text = "~~ Start of feed ~~"
                self.loadMoreSpinner.stopAnimating()
                return
            }
            if self.offset > 0 {
                self.messages.appendContentsOf(messages)
                if self.offset < self.messages.count {
                    let upper = min(self.offset+self.limit, self.messages.count)
                    self.tableView.insertRowsAtIndexPaths((self.offset..<upper).map{NSIndexPath(forRow:$0,inSection: 0)}, withRowAnimation: .Middle)
                    
                }
            }
            else {
                self.messages = messages
                self.tableView.reloadData()
            }
            self.loadMoreText.hidden = false
            self.loadMoreSpinner.stopAnimating()
        })
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if maximumOffset - currentOffset <= 10.0 && !didReachEndOfFeed {
            self.loadMoreText.hidden = true
            self.loadMoreSpinner.startAnimating()
            offset += limit
            self.loadData()
        }
    }


    @IBAction func toCatalog(sender: AnyObject) {
        self.performSegueWithIdentifier("toCatalog", sender: self)
    }
    
    func doneClicked(){
        shouldRemoveThemeFromHost()
        creator?.txtMessage.resignFirstResponder()
    }
    
    func registerForKeyboardNotifications()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        guard let info : NSDictionary = notification.userInfo! ,
            let tabController = self.tabBarController ,
            let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size else { return }
        assistantBottomConstraint.constant = keyboardSize.height - tabController.tabBar.frame.height
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
