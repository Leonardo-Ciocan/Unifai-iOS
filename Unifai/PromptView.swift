import UIKit

protocol PromptViewDelegate {
    func didSelectPromptSuggestionWithName(_ name:String)
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
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "PromptView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.backgroundColor = UIColor.clear
        
        self.addSubview(view)
        
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SuggestionsHeader(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50) , color:service?.color ?? UIColor.white)
        view.backgroundColor = service?.color ?? UIColor.white
        view.txtName.text = "SUGGESTIONS" + " (" + String(filteredSuggestions.count) + ")"
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell") as! SuggestionCell
        print((indexPath as NSIndexPath).row)
        cell.txtName.text = filteredSuggestions[(indexPath as NSIndexPath).row].title
        cell.txtMessage.text = filteredSuggestions[(indexPath as NSIndexPath).row].subtitle
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectPromptSuggestionWithName("@" + (service?.username)! + " " + filteredSuggestions[(indexPath as NSIndexPath).row].value)
    }
    
    func filterPromptsWithKeywords(_ keywords:[String]) {
        var filtered : [SuggestionItem] = self.suggestions
        keywords.forEach({ keyword in
            filtered = filtered.filter({
                $0.title.lowercased().contains(keyword.lowercased()) ||
                     $0.subtitle.lowercased().contains(keyword.lowercased()) ||
                    keyword == ""
            })
        })
        self.filteredSuggestions = filtered
        self.tableView.reloadData()
    }

}
