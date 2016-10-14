//
//  ActionRunnerViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 01/08/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class ActionRunnerViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {

    @IBOutlet weak var headerBackground: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgLogo: UIImageView!
    
    var messages : [Message] = []
    var resultMessage : Message?
    var action : Action?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        imgLogo.layer.shadowColor = UIColor.black.cgColor
        imgLogo.layer.shadowOffset = CGSize.zero
        imgLogo.layer.shadowOpacity = 0.35
        imgLogo.layer.shadowRadius = 15
        
        tableView.register(UINib(nibName: "MessageCell",bundle: nil), forCellReuseIdentifier: "MessageCell")
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0
        self.tableView!.tableFooterView = UIView()
        
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = currentTheme.backgroundColor
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Discard", style: .plain, target: self, action: #selector(discard))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Keep", style: .plain, target: self, action: #selector(keep))
        
        let service = TextUtils.extractService(action!.message)
        imgLogo.image = UIImage(named: (service?.username)!)
        self.headerBackground.backgroundColor = service?.color
        self.navigationController?.navigationBar.barTintColor = service?.color
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = UIColor.white
        
        self.view.backgroundColor = currentTheme.backgroundColor
        
        let message = Message(body: action!.message, type: .Text, payload: nil)
        messages = [message]
        Unifai.runAction(action!, completion: { msg in
            self.resultMessage = msg
            self.messages.append(msg)
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        cell.selectionStyle = .none
        cell.setMessage(messages[(indexPath as NSIndexPath).row] , shouldShowThreadCount: false)
        cell.hideTime = true
        cell.parentViewController = self
        return cell
    }
    
    
    @IBAction func keep(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func discard(_ sender: AnyObject) {
        if resultMessage != nil {
            Unifai.deleteThread((resultMessage?.threadID!)!, completion: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadAction(_ action:Action) {
        self.action = action
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
