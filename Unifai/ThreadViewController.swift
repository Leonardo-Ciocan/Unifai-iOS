import Foundation
import GSImageViewerController
import SafariServices
import UIKit

extension UITableView {
    func scrollToBottom(animated animated: Bool) {
        if self.contentSize.height < self.bounds.size.height { return }
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }
}

protocol ThreadVCDelegate {
    func feedShouldUpdate(message message:Message, forThread threadID:String)
}

class ThreadViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , MessageCreatorDelegate, MessageCellDelegate {
    
    var threadDelegate : ThreadVCDelegate?
    
    @IBOutlet weak var creatorAssistant: CreatorAssistant!
    
    
    @IBOutlet weak var barShadow: UIVisualEffectView!
    @IBOutlet weak var creatorShadow: UIView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var messageCreator: MessageCreator! {
        didSet {
            self.messageCreator.threadID = threadID
        }
    }
    var threadID : String?
    
    var messages : [Message] = [
    ]
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle


        super.viewDidLoad()
        
        
        self.tableView!.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        //self.tableView?.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 70))
        self.tableView!.separatorStyle = .None
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.navigationController?.navigationItem.title = "Loaded";
        self.messageCreator.creatorDelegate = self
        self.messageCreator.assistant = creatorAssistant
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 49 + 100))
        self.messageCreator.updateGeniusSuggestions(threadID!)
        creatorShadow.layer.shadowColor = UIColor.blackColor().CGColor
        creatorShadow.layer.shadowOffset = CGSizeZero
        creatorShadow.layer.shadowOpacity = 0.11
        creatorShadow.layer.shadowRadius = 10
        creatorShadow.layer.borderWidth = 0
        creatorShadow.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.2).CGColor
        
        messageCreator.parentViewController = self
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.clearColor() //Constants.appBrandColor.darkenColor(0.05)
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.translucent = true
        
        barShadow.layer.shadowColor = UIColor.blackColor().CGColor
        barShadow.layer.shadowOffset = CGSizeZero
        barShadow.layer.shadowOpacity = 0.11
        barShadow.layer.shadowRadius = 10
        barShadow.layer.borderWidth = 0
        barShadow.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.2).CGColor
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(keyboardWillShow),
                                                         name: UIKeyboardDidShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(keyboardWillHide),
                                                         name: UIKeyboardDidHideNotification,
                                                         object: nil)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func shouldSendMessageWithText(text: String, sourceRect: CGRect, sourceView: UIView) {
        messageCreator.txtMessage.becomeFirstResponder()
        animateAddingCharacter(text)
    }
    
    func animateAddingCharacter(consumableString:String) {
        messageCreator.txtMessage.text = messageCreator.txtMessage.text! + String(consumableString.characters.first!)
        messageCreator.textChanged(messageCreator)
        guard consumableString.characters.count > 1 else {
            let delay = 0.3 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.messageCreator.sendMessageOrSelectPlaceholder(self.messageCreator.txtMessage.text!, imageData: nil)
            }
            return
        }
        let delay = 0.015 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.animateAddingCharacter(consumableString.substringFromIndex(consumableString.startIndex.advancedBy(1)))
        }
    }
    
    func shouldAppendMessage(message: Message) {
        if !message.isFromUser {
            self.threadDelegate?.feedShouldUpdate(message:message, forThread:threadID!)
        }
        self.messages.append(message)
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow:messages.count-1,inSection:0)], withRowAnimation: .Bottom)
        self.tableView.endUpdates()
        let delay = 0.4 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.tableView.scrollToBottom(animated: true)
        }
    }
    
    func shouldThemeHostWithColor(color: UIColor) {
        UIView.animateWithDuration(1, animations: {
            },completion: { _ in
                self.navigationController?.navigationBar.barStyle =  .Black
                self.navigationController?.navigationBar.barTintColor =  color
                self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        })
    }
    
    func shouldRemoveThemeFromHost() {
        UIView.animateWithDuration(1, animations: {
            },completion: { _ in
                self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
                self.navigationController?.navigationBar.barTintColor = nil
                self.navigationController?.navigationBar.tintColor = currentTheme.foregroundColor
        })
    }
    
    func loadData(thread : String){
        self.threadID = thread
        Unifai.getServices({ services in
            Core.Services = services
            Unifai.getThread(thread , completion:{ threadMessages in
                self.navigationItem.title = String(threadMessages.count) + " messages"
                if self.spinner != nil {
                    self.spinner.stopAnimating()
                }
                self.messages = threadMessages
                self.tableView?.reloadData()
                let delay = 0.4 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue()) {
                    //self.tableView.scrollToBottom(animated: true)
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection:0) , atScrollPosition: .Top, animated: true)
                }
                if let lastMessage = threadMessages.last {
                    if lastMessage.type == .Prompt {
                        self.messageCreator.enablePromptModeWithSuggestions(lastMessage.service!, suggestions: (lastMessage.payload as! PromptPayload).suggestions, questionText: ((lastMessage.payload as! PromptPayload)).questionText)
                    }
                    else if self.messageCreator.isInPromptMode {
                        self.messageCreator.disablePromptMode()
                    }
                }
                
            })
        })
    }
    
    func didFinishAuthenticationFromMessage(message: Message?) {
        let msg = messages[messages.count-2].body
        messageCreator.txtMessage.becomeFirstResponder()
        animateAddingCharacter(msg)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.selectionStyle = .None
        cell.setMessage(messages[indexPath.row] , shouldShowThreadCount: false)
        
        cell.delegate = self
        cell.parentViewController = self
        
        return cell
    }
    
    func payloadImageTapped(senderA:UITapGestureRecognizer){
        let sender = senderA.view as! UIImageView
        let imageInfo      = GSImageInfo(image: sender.image!, imageMode: .AspectFit, imageHD: nil)
        let transitionInfo = GSTransitionInfo(fromView: sender)
        let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        self.presentViewController(imageViewer, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : currentTheme.foregroundColor , NSFontAttributeName : UIFont(name:"Helvetica",size:15)! ]
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        self.navigationController?.navigationBar.barTintColor = nil
        self.navigationController?.navigationBar.tintColor = currentTheme.foregroundColor
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = currentTheme.foregroundColor
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        keyboardShowOrHide(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        keyboardShowOrHide(notification)
    }
    
    private func keyboardShowOrHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey] else { return }
        
        let keyboardFrameEndRectFromView = view.convertRect(keyboardFrameEnd.CGRectValue, fromView: nil)
        UIView.animateWithDuration(1.0,
                                   delay: 0,
                                   options:[],
                                   animations: {
                                       self.rootView.frame = CGRectMake(0, 0, keyboardFrameEndRectFromView.size.width, keyboardFrameEndRectFromView.origin.y);

            }, completion: nil)
    }
    
    
//    func doneClicked(){
//        shouldRemoveThemeFromHost()
//        messageCreator?.txtMessage.resignFirstResponder()
//    }
    
    func didStartWriting() {
        //self.navigationItem.leftBarButtonItem = doneButton
    }
    
    func didFinishWirting() {
        //self.navigationItem.leftBarButtonItem = nil
    }
}
