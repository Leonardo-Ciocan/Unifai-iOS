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
    let activtyControl = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    @IBAction func logout(_ sender: AnyObject) {
        Unifai.logoutFromService((service?.username)!)
        settingsTab.isHidden = true
        tabs.removeSegment(at: 2, animated: true)
        homepageTableView.isHidden = false
        HUD.flash(.success, delay: 1)
        activtyControl.startAnimating()
        self.loadData(service)
    }
    
    override func viewDidLoad() {
        self.tableView!.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        self.homepageTableView!.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")

        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.homepageTableView!.rowHeight = UITableViewAutomaticDimension
        self.homepageTableView!.estimatedRowHeight = 64.0
        self.homepageTableView.delegate = self
        self.homepageTableView.dataSource = self
        
        navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage =  UIImage(named:"transparent")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activtyControl)
        activtyControl.startAnimating()
        self.tableView.alpha = 0
        self.view.backgroundColor = currentTheme.backgroundColor
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)!, NSForegroundColorAttributeName: UIColor.white]
        
        self.btnLogout.tintColor = self.service?.color
        
    
        self.settingsTab.isHidden = true
        updateLoggedInStatus()
    }
    
    func updateLoggedInStatus() {
        Unifai.isUserLoggedInToService((self.service?.username)!, completion: { loggedIn in
            if loggedIn {
                self.tabs.insertSegment(withTitle: "Account", at: 2, animated: true)
                self.settingsTab.backgroundColor = currentTheme.backgroundColor
                self.txtCurrentlyLoggedIn.textColor = currentTheme.foregroundColor
            }
        })
    }
    
    
    @IBAction func tabChanged(_ sender: AnyObject) {
        let index = tabs.selectedSegmentIndex
        if index == 1 {
            self.homepageTableView.isHidden = true
            self.tableView.isHidden = false
            self.settingsTab.isHidden = true
        }
        else if index == 0 {
            self.tableView.isHidden = true
            self.homepageTableView.isHidden = false
            self.settingsTab.isHidden = true

        }
        else if index == 2 {
            self.tableView.isHidden = true
            self.homepageTableView.isHidden = true
            self.settingsTab.isHidden = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.headerBackground.backgroundColor = service?.color
        self.navigationController?.navigationBar.barTintColor = service!.color
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location) else { return nil }
        
        guard let cell = tableView?.cellForRow(at: indexPath) else { return nil }
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "ThreadViewController") as? ThreadViewController else { return nil }
        
        detailVC.loadData(messages[(indexPath as NSIndexPath).row].threadID!)
        
        detailVC.preferredContentSize = CGSize(width: 0.0, height: 600)
        
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
        
    }
    
    var service : Service?
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func loadData(_ service:Service?){
        guard service != nil else{ return }
        self.service = service
        self.navigationItem.title = service?.name.uppercased()
        
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
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.alpha = 1
            })
        })
    }
    
    @IBAction func doneTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        activtyControl.startAnimating()
        loadData(self.service)
    }
    
    var selectedRow = 0
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (indexPath as NSIndexPath).row != 0 && tableView != homepageTableView else { return }
        
        selectedRow = (indexPath as NSIndexPath).row
        
        guard let detailVC = UIStoryboard(name: "Thread", bundle: nil).instantiateViewController(withIdentifier: "ThreadViewController") as? ThreadViewController else { return }
        
        detailVC.loadData(messages[selectedRow - 1].threadID!)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        cell.hideServiceMarkings = true
        cell.hideTime = true
        cell.selectionStyle = .none
        cell.parentViewController = self
        cell.setMessage(tableView == self.tableView ? messages[(indexPath as NSIndexPath).row] : homepage[(indexPath as NSIndexPath).row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == self.tableView ? messages.count : homepage.count
    }
    
    func shouldSendMessageWithText(_ text: String, sourceRect: CGRect, sourceView: UIView) {
        let runner = ActionRunnerViewController()
        runner.loadAction(Action(message: text, name: ""))
        
        let rootVC = UINavigationController(rootViewController: runner)
        rootVC.modalPresentationStyle = .popover
        rootVC.popoverPresentationController!.sourceView = sourceView
        rootVC.popoverPresentationController!.sourceRect = sourceRect
        rootVC.preferredContentSize = CGSize(width: 350,height: 500)
        self.present(rootVC, animated: true, completion: nil)
    }
    
    func didFinishAuthenticationFromMessage(_ message: Message?) {
        activtyControl.startAnimating()
        loadData(self.service)
        updateLoggedInStatus()
    }
    
}
