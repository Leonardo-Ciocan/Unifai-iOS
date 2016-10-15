import UIKit
import AlertOnboarding
import GSImageViewerController
import DGElasticPullToRefresh
import PKHUD

extension UIScrollView {
    func dg_stopScrollingAnimation() {}
}


class FeedViewController: UIViewController , UITableViewDelegate , MessageCellDelegate , ThreadVCDelegate, MessageCreatorDelegate , UITableViewDataSource {
    
    var mainSplitView : MainSplitView { return self.splitViewController as! MainSplitView }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCatalog: UIBarButtonItem!
    @IBOutlet weak var assistantBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var creatorAssistant: CreatorAssistant!
    @IBOutlet weak var creatorShadow: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var reloadPrompt: UIView!
    @IBOutlet weak var creator : MessageCreator?
    
    var processedMessageBodies : [String:NSAttributedString] = [:]
    var messages : [Message] = []
    var selectedRow = 0
    
    let loadMoreSpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let loadMoreText = UILabel()
    var didReachEndOfFeed = false
    
    var offset = 0
    let limit = 10
    
    override func viewDidLoad() {
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        
        self.tableView!.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .none
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        guard UserDefaults.standard.string(forKey: "token") != nil else{return}
        
        self.tabBarController?.title = "Feed"
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.white
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
        creator!.backgroundColor = UIColor.clear
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width , height: 110))
        
        let loadMoreFooter = UIView(frame: CGRect(x:0,y:0, width: self.view.frame.width,height: 55))
        loadMoreText.text = "Scroll to load more"
        loadMoreText.textColor = UIColor.gray
        loadMoreSpinner.hidesWhenStopped = true
        loadMoreText.isHidden = true
        
        loadMoreFooter.addSubview(loadMoreText)
        loadMoreFooter.addSubview(loadMoreSpinner)
        
        loadMoreText.snp_makeConstraints({ make in
            make.center.equalTo(loadMoreFooter)
        })
        
        loadMoreSpinner.snp_makeConstraints({ make in
            make.center.equalTo(loadMoreFooter)
        })
        
        tableView.tableFooterView = loadMoreFooter
        
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName : UIFont(name:"Helvetica",size:15)!, NSForegroundColorAttributeName: currentTheme.foregroundColor
        ]
        
        registerForKeyboardNotifications()
        self.navigationController?.navigationBar.tintColor = currentTheme.foregroundColor
        
        self.navigationController!.navigationBar.isHidden = true
        
        reloadPrompt.layer.shadowColor = UIColor.black.cgColor
        reloadPrompt.layer.shadowOffset = CGSize.zero
        reloadPrompt.layer.shadowOpacity = 0.11
        reloadPrompt.layer.shadowRadius = 10
        reloadPrompt.layer.borderWidth = 1
        reloadPrompt.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        
        creatorShadow.layer.shadowPath = CGPath(rect: creatorShadow.bounds, transform: nil)
        creatorShadow.layer.shadowColor = UIColor.black.cgColor
        creatorShadow.layer.shadowOffset = CGSize.zero
        creatorShadow.layer.shadowOpacity = 0.11
        creatorShadow.layer.shadowRadius = 10
        creatorShadow.layer.borderWidth = 0
        creatorShadow.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        
        visualEffectView.effect = UIBlurEffect(style:currentTheme.visualEffectStyle)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.navigationBar.isHidden = true
    }
    
    func feedShouldUpdate(message: Message, forThread threadID: String) {
        guard let indexToReplace = self.messages.index(where: { $0.threadID == threadID }) else { return }
        self.messages[indexToReplace] = message
        self.tableView.reloadData()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
    
    func loadData() {
        HUD.show(.labeledProgress(title: "Loading feed", subtitle: "Stand by"))
        Unifai.getFeed(fromOffset: offset, andAmount: limit, completion: { messages in
            if messages.count == 0 {
                self.didReachEndOfFeed = true
                self.loadMoreText.isHidden = false
                self.loadMoreText.text = "~~ Start of feed ~~"
                self.loadMoreSpinner.stopAnimating()
                return
            }
            if self.offset > 0 {
                self.messages.append(contentsOf: messages)
                if self.offset < self.messages.count {
                    let upper = min(self.offset+self.limit, self.messages.count)
                    self.tableView.insertRows(at: (self.offset..<upper).map{IndexPath(row:$0,section: 0)}, with: .middle)
                    
                }
            }
            else {
                self.messages = messages
                self.tableView.reloadData()
            }
            self.loadMoreText.isHidden = false
            self.loadMoreSpinner.stopAnimating()
            HUD.flash(.success, delay: 0.3)
        })
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if maximumOffset - currentOffset <= 10.0 && !didReachEndOfFeed {
            self.loadMoreText.isHidden = true
            self.loadMoreSpinner.startAnimating()
            offset += limit
            self.loadData()
        }
    }
    
    func registerForKeyboardNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(_ notification: Notification)
    {
        guard let info : NSDictionary = (notification as NSNotification).userInfo! as NSDictionary? ,
            let tabController = self.tabBarController ,
            let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        assistantBottomConstraint.constant = keyboardSize.height - tabController.tabBar.frame.height
    }
    
    func keyboardWillBeHidden(_ notification: Notification)
    {
        assistantBottomConstraint.constant = 0
    }
    
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedRow = (indexPath as NSIndexPath).row
        self.mainSplitView.selectedMessage = messages[(indexPath as NSIndexPath).row]
        self.navigationController!.navigationBar.isHidden = false
        self.splitViewController!.performSegue(withIdentifier: "toThread", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        cell.selectionStyle = .none
        cell.shouldShowText = !Settings.onlyTextOnFeed
        cell.setMessage(messages[(indexPath as NSIndexPath).row] , shouldShowThreadCount: true)
        cell.delegate = self
        cell.accessoryView = cell.imgLogo as UIView
        cell.imgLogo.contentMode = .scaleAspectFit
        cell.imgLogo.isUserInteractionEnabled = true
        cell.parentViewController = self
        cell.txtBody.isUserInteractionEnabled = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let msg = messages.remove(at: (indexPath as NSIndexPath).row)
            self.tableView.reloadData()
            Unifai.deleteThread(msg.threadID!, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func shouldThemeHostWithColor(_ color: UIColor) {
        UIView.animate(withDuration: 1, animations: {
            },completion: { _ in
                self.navigationController?.navigationBar.barStyle =  .black
                self.navigationController?.navigationBar.barTintColor =  color
                self.navigationController?.navigationBar.tintColor = UIColor.white
                self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)!, NSForegroundColorAttributeName: UIColor.white]
        })
    }
    
    func shouldRemoveThemeFromHost() {
        UIView.animate(withDuration: 1, animations: {
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
    
    func shouldAppendMessage(_ message: Message) {
        guard message.service != nil else { return }
        offset += 1
        self.messages.insert(message, at: 0)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row:0,section:0)], with: .automatic)
        self.tableView.endUpdates()
    }
    
    
    func didFinishAuthenticationFromMessage(_ message: Message?) {
        guard let message = message ,
            let threadID = message.threadID
            else { return }
        Unifai.getThread(threadID, completion: { threadMessages in
            guard threadMessages.count > 1 else { return }
            let messageToResend = threadMessages[threadMessages.count - 2]
            guard messageToResend.isFromUser else { return }
            Unifai.sendMessage(messageToResend.body, thread: threadID, completion: { answer in
                guard let indexToReplace = self.messages.index(where: { $0.id == message.id }) else { return }
                self.messages[indexToReplace] = answer
                self.tableView.reloadData()
            })
        })
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
    
    

}
