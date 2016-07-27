//
//  AutoCompletionSuggestions.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 24/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
protocol AutoCompletionSuggestionsDelegate {
    func didSelectAutocompletion(message : String)
}
class AutoCompletionSuggestions: UIView , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var suggestions : [CatalogItem] = []
    var filteredSuggestions : [CatalogItem] = []
    
    var actions : [Action] = []
    var filteredActions : [Action] = []
    
    var filterKeywords : [String] = []
    var delegate : AutoCompletionSuggestionsDelegate?
    
    var serviceColor : UIColor? {
        didSet {
            self.backgroundColor = serviceColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "AutoCompletionSuggestions", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(view);
        
        self.tableView.registerNib(UINib(nibName: "SuggestionCell",bundle: nil), forCellReuseIdentifier: "SuggestionCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.tableHeaderView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 20))
        self.tableView.tableFooterView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 50))
        self.tableView.separatorColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.separatorStyle = .None
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SuggestionsHeader(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50) , color:serviceColor ?? UIColor.whiteColor())
        view.backgroundColor = serviceColor
        view.txtName.text = ( (section == 0) ? "CATALOG" : "ACTIONS") + " (" + String( section == 0 ? filteredSuggestions.count : filteredActions.count) + ")"
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? filteredSuggestions.count : filteredActions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SuggestionCell") as! SuggestionCell
        print(indexPath.row)
        if indexPath.section == 0{
            cell.txtName.text = filteredSuggestions[indexPath.row].name
            cell.txtMessage.text = filteredSuggestions[indexPath.row].message
        }
        else {
            cell.txtName.text = filteredActions[indexPath.row].name
            cell.txtMessage.text = filteredActions[indexPath.row].message
        }
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didSelectAutocompletion(
            indexPath.section == 0 ? filteredSuggestions[indexPath.row].message : filteredActions[indexPath.row].message
        )
    }
    
    func filterSuggestionsWithKeywords(keywords:[String]) {
        self.filterKeywords = keywords
        var filtered : [CatalogItem] = self.suggestions
        self.filterKeywords.forEach({ keyword in
            filtered = filtered.filter({
                    $0.name.lowercaseString.containsString(keyword.lowercaseString) ||
                    $0.message.lowercaseString.containsString(keyword.lowercaseString) ||
                    keyword == ""
            })
        })
        
        var filteredActions : [Action] = self.actions
        self.filterKeywords.forEach({ keyword in
            filteredActions = filteredActions.filter({
                $0.name.lowercaseString.containsString(keyword.lowercaseString) ||
                    $0.message.lowercaseString.containsString(keyword.lowercaseString) ||
                    keyword == ""
            })
        })
        
        self.filteredSuggestions = filtered
        self.filteredActions = filteredActions
        self.tableView.reloadData()
    }


}
