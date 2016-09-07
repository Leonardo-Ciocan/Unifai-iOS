import UIKit
import DGElasticPullToRefresh
import DateTools

class DashboardViewController : UIViewController , UITableViewDelegate , UITableViewDataSource, MessageCellDelegate, DashboardEditorViewControllerDelegate{
    
    var messages : [Message] = []
    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var tutorialView: UIView!
    
    var activityControl : UIActivityIndicatorView?
    
    let txtTitle = UILabel()
    let txtSubtitle = UILabel()
    var timeUpdatingTimer : NSTimer?
    override func viewDidLoad() {
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor
        
        self.tableView!.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .SingleLine
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        txtTitle.text = "Dashboard"
        txtTitle.font = txtTitle.font.fontWithSize(13)
        txtSubtitle.text = "Updated 2 min ago"
        txtTitle.textColor = currentTheme.foregroundColor
        txtSubtitle.textColor = currentTheme.secondaryForegroundColor
        txtSubtitle.font = txtSubtitle.font.fontWithSize(13)
        txtTitle.textAlignment = .Center
        txtSubtitle.textAlignment = .Center
        
        let titleContainer = UIStackView(arrangedSubviews: [txtTitle, txtSubtitle])
        titleContainer.axis = .Vertical
        titleContainer.frame = CGRect(x: 0, y: 0, width: 200, height: 33)
        navigationItem.titleView = titleContainer
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.whiteColor()
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self!.loadData()
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(Constants.appBrandColor)
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)

        
        self.tableView!.separatorStyle = .None
        Cache.getDashboard({ messages in
            guard !self.hasDashboardNewerThanCacheBeenLoaded else { return }
            self.messages = messages
            self.tableView.reloadData()
            self.activityControl?.stopAnimating()
        })
        
        activityControl = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        let button = UIBarButtonItem(customView: activityControl!)
        self.navigationItem.rightBarButtonItem = button
        activityControl!.startAnimating()
        
        updateTimeLabel()
        self.timeUpdatingTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
        }
    
    var hasDashboardNewerThanCacheBeenLoaded = false
    
    override func viewDidAppear(animated: Bool) {
        hasDashboardNewerThanCacheBeenLoaded = true
        lastUpdatedDate = nil
        updateTimeLabel()
        Cache.getDashboard({ messages in
            self.messages = messages
            self.tableView.reloadData()
            self.loadData()
            self.activityControl?.stopAnimating()
        })
    }
    
    var lastUpdatedDate : NSDate?
    
    func updateTimeLabel() {
        if lastUpdatedDate == nil && self.txtSubtitle.text != "Your dashboard is empty" {
            self.txtSubtitle.text = "Loading..."
        }
        else if lastUpdatedDate != nil {
            if NSDate().timeIntervalSinceDate(lastUpdatedDate!) < 60 {
                self.txtSubtitle.text = "Updated just now"
            }
            else {
                self.txtSubtitle.text = "Updated " + (lastUpdatedDate?.shortTimeAgoSinceNow())! + " ago"
            }
        }
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
        self.loadData()
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
    
    func loadData(){
        lastUpdatedDate = nil
        updateTimeLabel()
        Unifai.getDashboard({ dashboardMessages in
            if dashboardMessages.count == 0 {
                self.txtSubtitle.text = "Your dashboard is empty"
                self.tutorialView.hidden = false
            }
            else {
                self.tutorialView.hidden = true
                self.lastUpdatedDate = NSDate()
                self.updateTimeLabel()
            }
            self.messages = dashboardMessages
            self.tableView?.reloadData()
            self.activityControl?.stopAnimating()
        })
    }
    
   
    
    
    var selectedRow = 0
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.selectionStyle = .None
        cell.setMessage(messages[indexPath.row])
        
        cell.imgLogo.contentMode = .ScaleAspectFit
        cell.imgLogo.userInteractionEnabled = true
        cell.hideTime = true
        cell.parentViewController = self
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "dashboardEdit" {
            guard let navigationController = segue.destinationViewController as? UINavigationController else { return }
            guard let editor = navigationController.viewControllers[0] as? DashboardEditorViewController else { return }
            editor.delegate = self
        }
    }
    
    func didUpdateDashboardItems() {
        //self.loadData()
    }
    
}
