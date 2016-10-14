import UIKit

class ProfileViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UIViewControllerPreviewingDelegate {
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    var messages : [ Message] = []
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor

        self.tableView!.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .none
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        

        
//        let segment = UISegmentedControl(items: ["Send messages" , "Settings"])
//        segment.selectedSegmentIndex = 0
//        navigationItem.titleView = segment
//        self.settingsButton.title = NSString(string: "\u{2699}") as String
//        if let font = UIFont(name: "Helvetica", size: 18.0) {
//            self.settingsButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
//        }
        
        self.tableView.addSubview(self.refreshControl)
        loadData()
        
        
        if( traitCollection.forceTouchCapability == .available){
            
            registerForPreviewing(with: self, sourceView: view)
            
        }
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        self.tabBarController?.tabBar.barStyle = currentTheme.barStyle
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            messages.remove(at: (indexPath as NSIndexPath).row)
            self.tableView.reloadData()
        }
    }
    
    
    func loadData(){
        Unifai.getUserProfile({ threadMessages in
            self.messages = threadMessages
            self.tableView?.reloadData()
            self.refreshControl.endRefreshing()
        })
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadData()
    }
    
    var selectedRow = 0
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = (indexPath as NSIndexPath).row
        self.performSegue(withIdentifier: "toThread", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toThread"{
            let destination = segue.destination as! ThreadViewController
            destination.loadData(messages[selectedRow].threadID!)
        }
        else if segue.identifier == "toSettings"{
            segue.destination.modalPresentationStyle = .popover
            segue.destination.popoverPresentationController!.barButtonItem = sender as? UIBarButtonItem
            
            segue.destination.preferredContentSize = CGSize(width: 300,height: 400)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        cell.selectionStyle = .none
        cell.setMessage(messages[(indexPath as NSIndexPath).row])
        cell.imgLogo.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
        
        cell.accessoryView = cell.imgLogo as UIView
        cell.imgLogo.contentMode = .scaleAspectFit
        cell.imgLogo.isUserInteractionEnabled = true
        return cell
    }
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "toProfile", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
}
