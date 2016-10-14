//
//  AutoCompletionSuggestions.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 24/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
protocol AutoCompletionSuggestionsDelegate {
    func didSelectAutocompletion(_ message : String)
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
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AutoCompletionSuggestions", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
        
        self.tableView.register(UINib(nibName: "SuggestionCell",bundle: nil), forCellReuseIdentifier: "SuggestionCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.tableHeaderView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 20))
        self.tableView.tableFooterView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 50))
        self.tableView.separatorColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.separatorStyle = .none
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SuggestionsHeader(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50) , color:serviceColor ?? UIColor.white)
        view.backgroundColor = serviceColor
        view.txtName.text = ( (section == 0) ? "CATALOG" : "ACTIONS") + " (" + String( section == 0 ? filteredSuggestions.count : filteredActions.count) + ")"
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? filteredSuggestions.count : filteredActions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell") as! SuggestionCell
        print((indexPath as NSIndexPath).row)
        if (indexPath as NSIndexPath).section == 0{
            cell.txtName.text = filteredSuggestions[(indexPath as NSIndexPath).row].name
            cell.txtMessage.text = filteredSuggestions[(indexPath as NSIndexPath).row].message
        }
        else {
            cell.txtName.text = filteredActions[(indexPath as NSIndexPath).row].name
            cell.txtMessage.text = filteredActions[(indexPath as NSIndexPath).row].message
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectAutocompletion(
            (indexPath as NSIndexPath).section == 0 ? filteredSuggestions[(indexPath as NSIndexPath).row].message : filteredActions[(indexPath as NSIndexPath).row].message
        )
    }
    
    func filterSuggestionsWithKeywords(_ keywords:[String]) {
        self.filterKeywords = keywords
        var filtered : [CatalogItem] = self.suggestions
        self.filterKeywords.forEach({ keyword in
            filtered = filtered.filter({
                    $0.name.lowercased().contains(keyword.lowercased()) ||
                    $0.message.lowercased().contains(keyword.lowercased()) ||
                    keyword == ""
            })
        })
        
        var filteredActions : [Action] = self.actions
        self.filterKeywords.forEach({ keyword in
            filteredActions = filteredActions.filter({
                $0.name.lowercased().contains(keyword.lowercased()) ||
                    $0.message.lowercased().contains(keyword.lowercased()) ||
                    keyword == ""
            })
        })
        
        self.filteredSuggestions = filtered
        self.filteredActions = filteredActions
        self.tableView.reloadData()
    }


}
