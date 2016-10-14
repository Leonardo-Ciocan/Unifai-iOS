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
        self.tableView!.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .none
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        guard UserDefaults.standard.string(forKey: "token") != nil else{return}
        
        self.tabBarController?.title = "Feed"
        print("loading view")
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        cell.selectionStyle = .none
        cell.setMessage(messages[(indexPath as NSIndexPath).row])
        
        cell.accessoryView = cell.imgLogo as UIView
        cell.imgLogo.contentMode = .scaleAspectFit
        cell.imgLogo.isUserInteractionEnabled = true
        cell.imgLogo.tag = (indexPath as NSIndexPath).row
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
}
