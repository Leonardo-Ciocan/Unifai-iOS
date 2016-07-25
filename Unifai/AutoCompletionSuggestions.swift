//
//  AutoCompletionSuggestions.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 24/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class AutoCompletionSuggestions: UIView , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var suggestions : [CatalogItem] = []
    var filteredSuggestions : [CatalogItem] = []
    
    var filterKeywords : [String] = []
    
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
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.separatorStyle = .None
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSuggestions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SuggestionCell") as! SuggestionCell
        cell.txtName.text = filteredSuggestions[indexPath.row].name
        cell.txtMessage.text = filteredSuggestions[indexPath.row].message
        return cell
    }
    
    func filterSuggestionsWithKeywords(keywords:[String]) {
        self.filterKeywords = keywords
        var filtered : [CatalogItem] = self.suggestions
        self.filterKeywords.forEach({ keyword in
            filtered = filtered.filter({
                $0.name.containsString(keyword) ||
                    $0.message.containsString(keyword) ||
                    keyword == ""
            })
        })
        self.filteredSuggestions = filtered
        self.tableView.reloadData()
    }


}
