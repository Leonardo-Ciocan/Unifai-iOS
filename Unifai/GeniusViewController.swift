//
//  GeniusViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 28/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
protocol GeniusViewControllerDelegate {
    func didSelectGeniusSuggestionWithMessage(message:String)
    func didSelectGeniusSuggestionWithLink(link:String)
    func didSelectGeniusSuggestionWithClipboardImage()
}

class GeniusViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var groups : [GeniusGroup] = []
    var delegate : GeniusViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "GeniusSuggestionCell" , bundle: nil), forCellReuseIdentifier: "GeniusSuggestionCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.navigationItem.title = "Genius"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneTapped))
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.applyCurrentTheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = GeniusGroupHeader(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 50))
        view.backgroundColor = currentTheme.backgroundColor
        view.txtName.text = groups[section].reason + ":"
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    @IBAction func doneTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groups.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].suggestions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GeniusSuggestionCell") as! GeniusSuggestionCell
        cell.loadData(groups[indexPath.section].suggestions[indexPath.row])
        cell.selectionStyle = .None
        cell.backgroundColor = currentTheme.backgroundColor
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let suggestion = groups[indexPath.section].suggestions[indexPath.row]
        switch suggestion.trigger {
        case .SendMessage:
            self.delegate?.didSelectGeniusSuggestionWithMessage(groups[indexPath.section].suggestions[indexPath.row].message)
        case .PasteImage:
            self.delegate?.didSelectGeniusSuggestionWithClipboardImage()
        case .OpenLink:
            self.delegate?.didSelectGeniusSuggestionWithLink(groups[indexPath.section].suggestions[indexPath.row].message)
        default:
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
