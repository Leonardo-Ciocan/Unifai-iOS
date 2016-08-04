import UIKit

protocol PromptViewDelegate {
    func didSelectPromptSuggestionWithName(name:String)
}
class PromptView: UIView , UITableViewDataSource , UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var service : Service? {
        didSet {
            guard service != nil else { return }
            self.backgroundColor = service?.color
        }
    }
    
    var suggestions : [SuggestionItem] = []
    var filteredSuggestions : [SuggestionItem] = []
    var delegate : PromptViewDelegate?
    
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
        let nib = UINib(nibName: "PromptView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        view.backgroundColor = UIColor.clearColor()
        
        self.addSubview(view)
        
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
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SuggestionsHeader(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50) , color:service?.color ?? UIColor.whiteColor())
        view.backgroundColor = service?.color ?? UIColor.whiteColor()
        view.txtName.text = "SUGGESTIONS" + " (" + String(filteredSuggestions.count) + ")"
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSuggestions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SuggestionCell") as! SuggestionCell
        print(indexPath.row)
        cell.txtName.text = filteredSuggestions[indexPath.row].title
        cell.txtMessage.text = filteredSuggestions[indexPath.row].subtitle
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didSelectPromptSuggestionWithName("@" + (service?.username)! + " " + filteredSuggestions[indexPath.row].value)
    }
    
    func filterPromptsWithKeywords(keywords:[String]) {
        var filtered : [SuggestionItem] = self.suggestions
        keywords.forEach({ keyword in
            filtered = filtered.filter({
                $0.title.lowercaseString.containsString(keyword.lowercaseString) ||
                     $0.subtitle.lowercaseString.containsString(keyword.lowercaseString) ||
                    keyword == ""
            })
        })
        self.filteredSuggestions = filtered
        self.tableView.reloadData()
    }

}
