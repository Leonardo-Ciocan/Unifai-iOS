import UIKit
import DGElasticPullToRefresh

class DashboardViewController : UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    var messages : [Message] = []
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
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
        
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)! ]

        self.tabBarController?.title = "Dashboard"
        
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.whiteColor()
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self!.loadData()
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(Constants.appBrandColor)
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)

        
        self.tableView!.separatorStyle = .None
        
        getServicesAndUser({ _ in
            Cache.getDashboard({ messages in
                self.messages = messages
                self.tableView.reloadData()
                self.loadData()
            })
        })
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
        Unifai.getDashboard({ threadMessages in
            self.messages = threadMessages
            self.tableView?.reloadData()
            self.refreshControl.endRefreshing()
        })
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        loadData()
    }
    
    var selectedRow = 0
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.selectionStyle = .None
        cell.setMessage(messages[indexPath.row])
        cell.imgLogo.addTarget(self, action: #selector(imageTapped), forControlEvents: .TouchUpInside)
        
        cell.accessoryView = cell.imgLogo as UIView
        cell.imgLogo.contentMode = .ScaleAspectFit
        cell.imgLogo.userInteractionEnabled = true
        cell.hideTime = true
        cell.parentViewController = self
        return cell
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("toProfile", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    @IBAction func logout(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
        NSUserDefaults.standardUserDefaults().synchronize()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
