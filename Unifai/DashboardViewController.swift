import UIKit
import DGElasticPullToRefresh
import DateTools

class DashboardViewController : UIViewController , UITableViewDelegate , UITableViewDataSource, MessageCellDelegate, DashboardEditorViewControllerDelegate{
    
    var messages : [Message] = []
    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var tutorialView: UIView!
    
    var activityControl : UIActivityIndicatorView?
    
    @IBOutlet weak var barShadow: UIView!
    let txtTitle = UILabel()
    let txtSubtitle = UILabel()
    var timeUpdatingTimer : Timer?
    override func viewDidLoad() {
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor
        
        self.tableView!.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .singleLine
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        txtTitle.text = "Dashboard"
        txtTitle.font = txtTitle.font.withSize(13)
        txtSubtitle.text = "Updated 2 min ago"
        txtTitle.textColor = UIColor.black
        txtSubtitle.textColor = UIColor.gray
        txtSubtitle.font = txtSubtitle.font.withSize(13)
        txtTitle.textAlignment = .center
        txtSubtitle.textAlignment = .center
        
        let titleContainer = UIStackView(arrangedSubviews: [txtTitle, txtSubtitle])
        titleContainer.axis = .vertical
        titleContainer.frame = CGRect(x: 0, y: 0, width: 200, height: 33)
        navigationItem.titleView = titleContainer
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.white
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self!.loadData()
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(Constants.appBrandColor)
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)

        
        self.tableView!.separatorStyle = .none
        Cache.getDashboard({ messages in
            guard !self.hasDashboardNewerThanCacheBeenLoaded else { return }
            self.messages = messages
            self.tableView.reloadData()
            self.activityControl?.stopAnimating()
        })
        
        activityControl = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        let button = UIBarButtonItem(customView: activityControl!)
        self.navigationItem.rightBarButtonItem = button
        activityControl!.startAnimating()
        
        updateTimeLabel()
        self.timeUpdatingTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.clear //Constants.appBrandColor.darkened(amount: (0.05)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        //self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.isTranslucent = true
        
        barShadow.layer.shadowPath = CGPath(rect: barShadow.bounds, transform: nil)
        barShadow.layer.shadowColor = UIColor.black.cgColor
        barShadow.layer.shadowOffset = CGSize.zero
        barShadow.layer.shadowOpacity = 0.11
        barShadow.layer.shadowRadius = 10
        barShadow.layer.borderWidth = 0
        barShadow.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        
    }
    
    var hasDashboardNewerThanCacheBeenLoaded = false
    
    override func viewDidAppear(_ animated: Bool) {
        hasDashboardNewerThanCacheBeenLoaded = true
        lastUpdatedDate = nil
        updateTimeLabel()
        self.loadData()
    }
    
    var lastUpdatedDate : Date?
    
    func updateTimeLabel() {
        if lastUpdatedDate == nil && self.txtSubtitle.text != "Your dashboard is empty" {
            self.txtSubtitle.text = "Loading..."
        }
        else if lastUpdatedDate != nil {
            if Date().timeIntervalSince(lastUpdatedDate!) < 60 {
                self.txtSubtitle.text = "Updated just now"
            }
            else {
                self.txtSubtitle.text = "Updated " + ((lastUpdatedDate as NSDate?)?.shortTimeAgoSinceNow())! + " ago"
            }
        }
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
        self.loadData()
    }
    
    func loadData(){
        lastUpdatedDate = nil
        updateTimeLabel()
        Unifai.getDashboard({ dashboardMessages in
            if dashboardMessages.count == 0 {
                self.txtSubtitle.text = "Your dashboard is empty"
                self.tutorialView.isHidden = false
            }
            else {
                self.tutorialView.isHidden = true
                self.lastUpdatedDate = Date()
                self.updateTimeLabel()
            }
            self.messages = dashboardMessages
            self.tableView?.reloadData()
            self.activityControl?.stopAnimating()
        })
    }
    
   
    
    
    var selectedRow = 0
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        cell.selectionStyle = .none
        cell.setMessage(messages[(indexPath as NSIndexPath).row])
        
        cell.imgLogo.contentMode = .scaleAspectFit
        cell.imgLogo.isUserInteractionEnabled = true
        cell.hideTime = true
        cell.parentViewController = self
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dashboardEdit" {
            guard let navigationController = segue.destination as? UINavigationController else { return }
            guard let editor = navigationController.viewControllers[0] as? DashboardEditorViewController else { return }
            editor.delegate = self
        }
    }
    
    func didUpdateDashboardItems() {
        //self.loadData()
    }
    
}
