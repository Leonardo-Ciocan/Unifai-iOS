import UIKit
import PKHUD

class ServiceProfileViewcontroller: UIViewController , UITableViewDelegate , UITableViewDataSource ,UIViewControllerPreviewingDelegate, MessageCellDelegate {
    @IBOutlet weak var tabs: UISegmentedControl!
    
    @IBOutlet weak var txtCurrentlyLoggedIn: UILabel!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var settingsTab: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerBackground: UIView!
    var messages : [Message] = []
    var homepage : [Message] = []
    
    @IBOutlet weak var homepageTableView: UITableView!
    let activtyControl = UIActivityIndicatorView(activityIndicatorStyle: .White)
    
    @IBAction func logout(sender: AnyObject) {
        Unifai.logoutFromService((service?.username)!)
        settingsTab.hidden = true
        tabs.removeSegmentAtIndex(2, animated: true)
        homepageTableView.hidden = false
        HUD.flash(.Success, delay: 1)
    }
    
    override func viewDidLoad() {
        self.tableView!.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        self.homepageTableView!.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")

        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .None
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.homepageTableView!.rowHeight = UITableViewAutomaticDimension
        self.homepageTableView!.estimatedRowHeight = 64.0
        self.homepageTableView.delegate = self
        self.homepageTableView.dataSource = self
        
        navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage =  UIImage(named:"transparent")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activtyControl)
        activtyControl.startAnimating()
        self.tableView.alpha = 0
        self.view.backgroundColor = currentTheme.backgroundColor
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.btnLogout.tintColor = self.service?.color
        
    
        self.settingsTab.hidden = true
        updateLoggedInStatus()
    }
    
    func updateLoggedInStatus() {
        Unifai.isUserLoggedInToService((self.service?.username)!, completion: { loggedIn in
            if loggedIn {
                self.tabs.insertSegmentWithTitle("Account", atIndex: 2, animated: true)
                self.settingsTab.backgroundColor = currentTheme.backgroundColor
                self.txtCurrentlyLoggedIn.textColor = currentTheme.foregroundColor
            }
        })
    }
    
    
    @IBAction func tabChanged(sender: AnyObject) {
        let index = tabs.selectedSegmentIndex
        if index == 1 {
            self.homepageTableView.hidden = true
            self.tableView.hidden = false
            self.settingsTab.hidden = true
        }
        else if index == 0 {
            self.tableView.hidden = true
            self.homepageTableView.hidden = false
            self.settingsTab.hidden = true

        }
        else if index == 2 {
            self.tableView.hidden = true
            self.homepageTableView.hidden = true
            self.settingsTab.hidden = false
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
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
        self.navigationItem.title = service?.name.uppercaseString
        
//        let titleImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 50, height: 50))
//        titleImageView.image = UIImage(named: (service?.username)!)
//        titleImageView.contentMode = .ScaleAspectFit
//        self.navigationItem.titleView = titleImageView
//        
        Unifai.getProfile(service!.username , completion: { homepage , threadMessages in
            self.messages = threadMessages
            self.homepage = homepage
            self.homepageTableView.reloadData()
            self.tableView?.reloadData()
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
        guard indexPath.row != 0 else { return }
        selectedRow = indexPath.row
        
        guard let detailVC = UIStoryboard(name: "Thread", bundle: nil).instantiateViewControllerWithIdentifier("ThreadViewController") as? ThreadViewController else { return }
        
        detailVC.loadData(messages[selectedRow - 1].threadID!)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.hideServiceMarkings = true
        cell.hideTime = true
        cell.selectionStyle = .None
        cell.parentViewController = self
        cell.setMessage(tableView == self.tableView ? messages[indexPath.row] : homepage[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == self.tableView ? messages.count : homepage.count
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
    
    func didFinishAuthenticationFromMessage(message: Message?) {
        loadData(self.service)
        updateLoggedInStatus()
    }
    
}
