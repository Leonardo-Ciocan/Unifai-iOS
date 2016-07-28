//
//  ThreadViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 26/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation
import SlackTextViewController
import GSImageViewerController
import SafariServices
import UIKit

class ThreadViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , MessageCreatorDelegate  {
    
    
    @IBOutlet weak var creatorAssistant: CreatorAssistant!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var rootView: UIView!
    @IBOutlet weak var messageCreator: MessageCreator!
    var threadID : String?
    
    var messages : [Message] = [
    ]
    @IBOutlet weak var tableView: UITableView!
    let doneButton = UIBarButtonItem()

    override func viewDidLoad() {
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        doneButton.action = #selector(doneClicked)
        doneButton.title = "Done"
        doneButton.style = .Done

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

        messageCreator.parentViewController = self
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(keyboardWillShow),
                                                         name: UIKeyboardDidShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(keyboardWillHide),
                                                         name: UIKeyboardDidHideNotification,
                                                         object: nil)
        
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)! ]
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func didSelectService(service: Service?) {
        UIView.animateWithDuration(1, animations: {
            },completion: { _ in
                self.navigationController?.navigationBar.barStyle = service == nil ? currentTheme.barStyle : .Black
                self.navigationController?.navigationBar.barTintColor = service == nil ? nil : service!.color
                self.navigationController?.navigationBar.tintColor = service == nil ? currentTheme.foregroundColor : UIColor.whiteColor()
        })
    }
    
    func loadData(thread : String){
        self.threadID = thread
        //this is a thread view
        Unifai.getServices({ services in
            Core.Services = services
            Unifai.getThread(thread , completion:{ threadMessages in
                self.navigationItem.title = String(threadMessages.count) + " messages"
                if self.spinner != nil {
                    self.spinner.stopAnimating()
                }
                self.messages = threadMessages
                self.tableView?.reloadData()
                self.tableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1,inSection:0), atScrollPosition: .Bottom, animated: true)
            })
        })
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.selectionStyle = .None
        cell.setMessage(messages[indexPath.row] , shouldShowThreadCount: false)
        
        
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
    
    func sendMessage(message: String) {
        self.messages.append(Message(body: message, type: .Text, payload: nil))
        self.tableView?.reloadData()
        self.tableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1,inSection:0), atScrollPosition: .Bottom, animated: true)
        
        Unifai.sendMessage( message, thread: self.threadID!, completion: { (success) in
                self.loadData(self.threadID!)
        })
    }
    
    func sendMessage(message: String, imageData: NSData) {
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        keyboardShowOrHide(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        keyboardShowOrHide(notification)
    }
    
    private func keyboardShowOrHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]else { return }
        guard let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] else { return }
        guard let keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey] else { return }
        
        let curveOption = UIViewAnimationOptions(rawValue: UInt(curve.integerValue << 16))
        let keyboardFrameEndRectFromView = view.convertRect(keyboardFrameEnd.CGRectValue, fromView: nil)
        UIView.animateWithDuration(duration.doubleValue ?? 1.0,
                                   delay: 0,
                                   options: [curveOption, .BeginFromCurrentState],
                                   animations: { () -> Void in
                                       self.rootView.frame = CGRectMake(0, 0, keyboardFrameEndRectFromView.size.width, keyboardFrameEndRectFromView.origin.y);

            }, completion: nil)
    }
    
    func doneClicked(){
        messageCreator?.txtMessage.resignFirstResponder()
    }
    
    func didStartWriting() {
        self.navigationItem.leftBarButtonItem = doneButton
    }
    
    func didFinishWirting() {
        self.navigationItem.leftBarButtonItem = nil
    }
    
    
    func chooseAction() {
        let menu = UIAlertController(title: "Run an action", message: "", preferredStyle: .ActionSheet)
        
        Unifai.getActions({ actions in
            for action in actions{
                let item = UIAlertAction(title: action.name, style: .Default, handler: { (alert:UIAlertAction!) -> Void in
                    if let selected = actions.filter({$0.name == alert.title}).first{
                        self.sendMessage(selected.message)
                    }
                })
                menu.addAction(item)
            }
            menu.addAction(UIAlertAction(title: "Cancel" , style: .Cancel , handler: nil))
            self.presentViewController(menu, animated: true, completion: nil)
        })
    }

}
