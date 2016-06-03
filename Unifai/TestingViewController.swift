//
//  TestingViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 02/06/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class TestingViewController : UIViewController , UITableViewDelegate , UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var messages : [Message] = [
        
    ]
    
    
    override func viewDidLoad() {
        self.tableView!.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .None
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        guard NSUserDefaults.standardUserDefaults().stringForKey("token") != nil else{return}
        
        self.tabBarController?.title = "Feed"
        print("loading view")
        Unifai.getServices({ services in
            Core.Services = services
            print("AQUIRED SERVICES")
            Unifai.getUserInfo({username , email in
                Core.Username = username
//                
//                let item1 = CardListPayloadItem()
//                item1.title = "Wisconsin Democrats To Vote On Ending Superdelegates"
//                item1.imageURL = "https://b.thumbs.redditmedia.com/7oGJLtC95d2W9N_WybDoFgOrsjF4CzYVDQf7JKopJBg.jpg"
//                
//                let item2 = CardListPayloadItem()
//                item2.title = "Pebble Core gets Amazon Alexa integration."
//                item2.imageURL = "https://b.thumbs.redditmedia.com/Opy9G8Ku-3vjaSq66GHltBNkXS5kLgnGJmU5oiThfRk.jpg"
//                
//                let payload = CardListPayload()
//                payload.items = [item1,item2]
//                
//                self.messages.append(Message(body: "Hello world", type: .CardList, payload: payload, service: services[1]))
                self.tableView.reloadData()
            })
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.selectionStyle = .None
        cell.setMessage(messages[indexPath.row])
        
        cell.accessoryView = cell.imgLogo as UIView
        cell.imgLogo.contentMode = .ScaleAspectFit
        cell.imgLogo.userInteractionEnabled = true
        cell.imgLogo.tag = indexPath.row
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
}
