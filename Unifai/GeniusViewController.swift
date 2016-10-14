//
//  GeniusViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 28/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
protocol GeniusViewControllerDelegate {
    func didSelectGeniusSuggestionWithMessage(_ message:String)
    func didSelectGeniusSuggestionWithLink(_ link:String)
    func didSelectGeniusSuggestionWithClipboardImage()
}

class GeniusViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var groups : [GeniusGroup] = []
    var delegate : GeniusViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "GeniusSuggestionCell" , bundle: nil), forCellReuseIdentifier: "GeniusSuggestionCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.navigationItem.title = "Genius"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.applyCurrentTheme()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = GeniusGroupHeader(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 50))
        view.backgroundColor = currentTheme.backgroundColor
        view.txtName.text = groups[section].reason + ":"
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    @IBAction func doneTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeniusSuggestionCell") as! GeniusSuggestionCell
        cell.loadData(groups[(indexPath as NSIndexPath).section].suggestions[(indexPath as NSIndexPath).row])
        cell.selectionStyle = .none
        cell.backgroundColor = currentTheme.backgroundColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suggestion = groups[(indexPath as NSIndexPath).section].suggestions[(indexPath as NSIndexPath).row]
        switch suggestion.trigger {
        case .sendMessage:
            self.delegate?.didSelectGeniusSuggestionWithMessage(groups[(indexPath as NSIndexPath).section].suggestions[(indexPath as NSIndexPath).row].message)
        case .pasteImage:
            self.delegate?.didSelectGeniusSuggestionWithClipboardImage()
        case .openLink:
            self.delegate?.didSelectGeniusSuggestionWithLink(groups[(indexPath as NSIndexPath).section].suggestions[(indexPath as NSIndexPath).row].message)
        }
        self.dismiss(animated: true, completion: nil)
    }

}
