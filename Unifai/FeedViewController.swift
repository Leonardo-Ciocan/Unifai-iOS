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
        self.navigationItem.leftBarButtonItem = doneButton
    }
    
    func didFinishWirting() {
        self.navigationItem.leftBarButtonItem = nil
    }
    
    func shouldAppendMessage(message: Message) {
        guard message.service != nil else { return }
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

class FeedViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , MessageCellDelegate , ThreadVCDelegate{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCatalog: UIBarButtonItem!
    @IBOutlet weak var assistantBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var creatorAssistant: CreatorAssistant!
    
    var messages : [Message] = []
    var selectedRow = 0
    var mainSplitView : MainSplitView {
        return self.splitViewController as! MainSplitView
    }
    let doneButton = UIBarButtonItem()
    var creator : MessageCreator?
    
    
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
        
        self.navigationItem.title = "Feed"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)!, NSForegroundColorAttributeName: currentTheme.foregroundColor]
        
        registerForKeyboardNotifications()
        self.navigationController?.navigationBar.tintColor = currentTheme.foregroundColor
        
        self.navigationController!.navigationBar.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
    }
    
    func feedShouldUpdate(message message: Message, forThread threadID: String) {
        guard let indexToReplace = self.messages.indexOf({ $0.threadID == threadID }) else { return }
        self.messages[indexToReplace] = message
        self.tableView.reloadData()
    }
    
    func shouldRefreshData() {
        loadData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
    
    func loadData() {
        Unifai.getFeed({ threadMessages in
            let diff = threadMessages.count - self.messages.count
            if diff > 0 {
                self.messages = threadMessages
                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths((0..<diff).map{ NSIndexPath(forRow:$0,inSection: 0)}, withRowAnimation: .Automatic)
                self.tableView.endUpdates()
            }
            else {
                self.messages = threadMessages
                self.tableView.reloadData()
            }
            self.creator?.updateGeniusSuggestionsLocally()
        })
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
