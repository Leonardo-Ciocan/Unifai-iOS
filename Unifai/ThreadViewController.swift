//
//  ThreadViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 26/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation
import SlackTextViewController

class ThreadViewController: SLKTextViewController  {
    
    var messages : [Message] = [
        Message(body: "Hello world", type: .Text , payload: nil),
        Message(body: "What's up", type: .Text , payload: nil , service: Service(name: "Skyscanner", color: UIColor.blueColor())),
        Message(body: "Nothin", type: .Text , payload: nil),
        Message(body: "This is a very long message that should wrap around to the next line", type: .Text , payload: nil , service: Service(name: "Budget", color: UIColor.greenColor())),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        self.inverted=false
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView?.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 70))
        self.tableView!.separatorStyle = .None
        self.registerPrefixesForAutoCompletion([""])
        
        
        if NSUserDefaults.standardUserDefaults().stringForKey("token") != nil{
            Unifai.getServices({ services in
                Core.Services = services
                Unifai.getFeed({ threadMessages in
                    self.messages = threadMessages
                    self.tableView?.reloadData()
                })
            })
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.selectionStyle = .None
        cell.setMessage(messages[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func didPressRightButton(sender: AnyObject?) {
        self.textView.refreshFirstResponder()
        
        Unifai.sendMessage( self.textView.text, completion: nil)
        
        self.messages.append(Message(body: self.textView.text, type: .Text, payload: nil))
        self.tableView?.reloadData()
        self.textView.text = ""
        
    }
}
