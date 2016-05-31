import UIKit

class DashboardViewController : UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    var messages : [Message] = []
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        self.tableView!.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .SingleLine
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 33, height: 33))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "logo")
        imageView.image = image
        navigationItem.titleView = imageView
        
        self.tabBarController?.title = "Dashboard"
        self.tableView.addSubview(self.refreshControl)
        self.tableView!.separatorStyle = .None
        
        loadData()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            messages.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
        }
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
