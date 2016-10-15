import Foundation
import GSImageViewerController
import SafariServices
import UIKit

extension UITableView {
    func scrollToBottom(animated: Bool) {
        if self.contentSize.height < self.bounds.size.height { return }
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }
}

protocol ThreadVCDelegate {
    func feedShouldUpdate(message:Message, forThread threadID:String)
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

    @IBOutlet weak var creatorBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle


        super.viewDidLoad()
        
        
        self.tableView!.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        //self.tableView?.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 70))
        self.tableView!.separatorStyle = .none
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.navigationController?.navigationItem.title = "Loaded";
        self.messageCreator.creatorDelegate = self
        self.messageCreator.assistant = creatorAssistant
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 49 + 100 + 10))
        self.messageCreator.updateGeniusSuggestions(threadID!)
        creatorShadow.layer.shadowColor = UIColor.black.cgColor
        creatorShadow.layer.shadowOffset = CGSize.zero
        creatorShadow.layer.shadowOpacity = 0.11
        creatorShadow.layer.shadowRadius = 10
        creatorShadow.layer.borderWidth = 0
        creatorShadow.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        
        messageCreator.parentViewController = self
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.clear //Constants.appBrandColor.darkened(amount: (0.05)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = true
        
        barShadow.layer.shadowColor = UIColor.black.cgColor
        barShadow.layer.shadowOffset = CGSize.zero
        barShadow.layer.shadowOpacity = 0.11
        barShadow.layer.shadowRadius = 10
        barShadow.layer.borderWidth = 0
        barShadow.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        
        
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(keyboardWillShow),
                                                         name: NSNotification.Name.UIKeyboardDidShow,
                                                         object: nil)
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(keyboardWillHide),
                                                         name: NSNotification.Name.UIKeyboardDidHide,
                                                         object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func shouldSendMessageWithText(_ text: String, sourceRect: CGRect, sourceView: UIView) {
        messages.append(Message(body: text, type: .text, payload: nil))
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row:messages.count-1,section:0)], with: .bottom)
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section:0) , at: .top, animated: true)
        updatePromptStatus()
        Unifai.sendMessage(text, thread: threadID!, completion: {
            msg in
            if !msg.isFromUser {
                self.threadDelegate?.feedShouldUpdate(message:msg, forThread:self.threadID!)
            }
            self.messages.append(msg)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row:self.messages.count-1,section:0)], with: .bottom)
            self.tableView.endUpdates()
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section:0) , at: .top, animated: true)
            self.updatePromptStatus()
        })
    }
    
    func shouldAppendMessage(_ message: Message) {
        if !message.isFromUser {
            self.threadDelegate?.feedShouldUpdate(message:message, forThread:threadID!)
        }
        self.messages.append(message)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row:messages.count-1,section:0)], with: .bottom)
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section:0) , at: .top, animated: true)
        updatePromptStatus()
    }
    
    func shouldThemeHostWithColor(_ color: UIColor) {
        UIView.animate(withDuration: 1, animations: {
            },completion: { _ in
                self.navigationController?.navigationBar.barStyle =  .black
                self.navigationController?.navigationBar.barTintColor =  color
                self.navigationController?.navigationBar.tintColor = UIColor.white
        })
    }
    
    func shouldRemoveThemeFromHost() {
        UIView.animate(withDuration: 1, animations: {
            },completion: { _ in
                self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
                self.navigationController?.navigationBar.barTintColor = nil
                self.navigationController?.navigationBar.tintColor = currentTheme.foregroundColor
        })
    }
    
    func loadData(_ thread : String){
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
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    //self.tableView.scrollToBottom(animated: true)
                    self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section:0) , at: .top, animated: true)
                }
                self.updatePromptStatus()
            })
        })
    }
    
    func updatePromptStatus() {
        if let lastMessage = messages.last {
            if lastMessage.type == .prompt {
                self.messageCreator.enablePromptModeWithSuggestions(lastMessage.service!, suggestions: (lastMessage.payload as! PromptPayload).suggestions, questionText: ((lastMessage.payload as! PromptPayload)).questionText)
            }
            else if self.messageCreator.isInPromptMode {
                self.messageCreator.disablePromptMode()
            }
        }
    }
    
    func didFinishAuthenticationFromMessage(_ message: Message?) {
        let text = messages[messages.count-2].body
        messages.append(Message(body: text, type: .text, payload: nil))
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row:messages.count-1,section:0)], with: .bottom)
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section:0) , at: .top, animated: true)
        updatePromptStatus()
        Unifai.sendMessage(text, thread: threadID!, completion: {
            msg in
            if !msg.isFromUser {
                self.threadDelegate?.feedShouldUpdate(message:msg, forThread:self.threadID!)
            }
            self.messages.append(msg)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row:self.messages.count-1,section:0)], with: .bottom)
            self.tableView.endUpdates()
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section:0) , at: .top, animated: true)
            self.updatePromptStatus()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        cell.selectionStyle = .none
        cell.setMessage(messages[(indexPath as NSIndexPath).row] , shouldShowThreadCount: false)
        
        cell.delegate = self
        cell.parentViewController = self
        
        return cell
    }
    
    func payloadImageTapped(_ senderA:UITapGestureRecognizer){
        let sender = senderA.view as! UIImageView
        let imageInfo      = GSImageInfo(image: sender.image!, imageMode: .aspectFit, imageHD: nil)
        let transitionInfo = GSTransitionInfo(fromView: sender)
        let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        self.present(imageViewer, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : currentTheme.foregroundColor , NSFontAttributeName : UIFont(name:"Helvetica",size:15)! ]
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        self.navigationController?.navigationBar.barTintColor = nil
        self.navigationController?.navigationBar.tintColor = currentTheme.foregroundColor
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = currentTheme.foregroundColor
        
    }
    
    
    func keyboardWillShow(_ notification: Notification) {
        keyboardShowOrHide(notification)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        keyboardShowOrHide(notification)
    }
    
    fileprivate func keyboardShowOrHide(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else {return}
        guard let keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey] else { return }
        
        let keyboardFrameEndRectFromView = view.convert((keyboardFrameEnd as AnyObject).cgRectValue, from: nil)
        UIView.animate(withDuration: 1.0,
                                   delay: 0,
                                   options:[],
                                   animations: {
                                       self.rootView.frame = CGRect(x: 0, y: 0, width: keyboardFrameEndRectFromView.size.width, height: keyboardFrameEndRectFromView.origin.y);

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
