    import UIKit

protocol DashboardEditorViewControllerDelegate {
    func didUpdateDashboardItems()
}

class DashboardEditorViewController: UIViewController , UITableViewDataSource , UITableViewDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var suggestionsTableView: UITableView!
    
    @IBOutlet weak var suggestionsView: UIView!

    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var suggestionsBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet
    var tableView: UITableView!
    
    var items : [String] = []
    var delegate : DashboardEditorViewControllerDelegate?
    
    @IBOutlet weak var barShadow: UIView!
    @IBOutlet weak var txtInstructions: UILabel!
    var btnSave : UIBarButtonItem?
    
    let txtTitle = UILabel()
    let txtSubtitle = UILabel()
    var dashboardSuggestions : [CatalogItem] = []
    var allSuggestions : [CatalogItem] = []
    
    @IBOutlet weak var txtMessage: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = currentTheme.backgroundColor
        self.tableView.backgroundColor = currentTheme.backgroundColor
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 64.0

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.editing = true
        self.tableView.registerNib(UINib(nibName: "DashboardEditorCell", bundle: nil), forCellReuseIdentifier: "DashboardEditorCell")
        self.tableView.tableFooterView = UIView()
        self.txtMessage.delegate = self
        
        txtTitle.text = "Editing dashboard"
        txtTitle.font = txtTitle.font.fontWithSize(13)
        txtSubtitle.text = "Loading..."
        txtTitle.textColor = UIColor.grayColor()
        txtSubtitle.textColor = UIColor.grayColor()
        txtSubtitle.font = txtSubtitle.font.fontWithSize(13)
        txtTitle.textAlignment = .Center
        txtSubtitle.textAlignment = .Center
        
        let titleContainer = UIStackView(arrangedSubviews: [txtTitle, txtSubtitle])
        titleContainer.axis = .Vertical
        titleContainer.frame = CGRect(x: 0, y: 0, width: 200, height: 33)
        navigationItem.titleView = titleContainer
        
        self.btnSave = UIBarButtonItem(title: "Save", style: .Done, target: self, action: #selector(done))
        self.navigationItem.rightBarButtonItem = nil
        loadData()
        
        self.allSuggestions = Core.Catalog.values.flatMap({ $0 }).filter({ $0.isSuitableForDashboard })
        self.dashboardSuggestions = Core.Catalog.values.flatMap({ $0 }).filter({ $0.isSuitableForDashboard })
        
        self.suggestionsTableView.registerNib(UINib(nibName: "SuggestionCell",bundle: nil), forCellReuseIdentifier: "SuggestionCell")
        self.suggestionsTableView.dataSource = self
        self.suggestionsTableView.delegate = self
        self.suggestionsTableView!.rowHeight = UITableViewAutomaticDimension
        self.suggestionsTableView.estimatedRowHeight = 100
        self.suggestionsTableView.separatorColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.suggestionsTableView.separatorInset = UIEdgeInsetsZero
        self.suggestionsTableView.separatorStyle = .None
        self.suggestionsTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 64 + 40))
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.clearColor() //Constants.appBrandColor.darkenColor(0.05)
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.translucent = true
        
        barShadow.layer.shadowPath = CGPathCreateWithRect(barShadow.bounds, nil)
        barShadow.layer.shadowColor = UIColor.blackColor().CGColor
        barShadow.layer.shadowOffset = CGSizeZero
        barShadow.layer.shadowOpacity = 0.15
        barShadow.layer.shadowRadius = 5
        barShadow.layer.borderWidth = 0
        barShadow.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.2).CGColor
        
        txtMessage.textColor = UIColor.blackColor()
        txtMessage.layer.masksToBounds = true
        txtMessage.tintColor = UIColor.blackColor()
        
        
        
        txtMessage.attributedPlaceholder = NSAttributedString(string: "Enter any message..." ,
                                                              attributes:[NSForegroundColorAttributeName: UIColor.grayColor()])
        
        
        txtMessage.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.05)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        txtMessage.leftViewMode = .Always
        txtMessage.leftView = leftView
        
        txtMessage.addTarget(
            self,
            action: #selector(textDidChange),
            forControlEvents: .EditingChanged
        )
        
        registerForKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.suggestionsBottomConstraint.constant = keyboardSize.height
            self.tableViewBottomConstraint.constant = keyboardSize.height
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.suggestionsBottomConstraint.constant = 0
        self.tableViewBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func textDidChange() {
        let text = txtMessage.text
        let wordsInQuery = (text!.componentsSeparatedByString(" "))
        var filtered : [CatalogItem] = self.allSuggestions
            wordsInQuery.forEach({ keyword in
                filtered = filtered.filter({
                    $0.name.lowercaseString.containsString(keyword.lowercaseString) ||
                        $0.message.lowercaseString.containsString(keyword.lowercaseString) ||
                        keyword == ""
                })
            })
        self.dashboardSuggestions = filtered
        self.suggestionsTableView.reloadData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        createOrHightlightToken()
        return false
    }
    
    func createOrHightlightToken() {
        let placeholderRanges = TextUtils.getPlaceholderPositionsInMessage((txtMessage?.text)!)
        if placeholderRanges.count > 0 {
            let range = placeholderRanges[0]
            let start = txtMessage!.positionFromPosition(txtMessage!.beginningOfDocument, offset: range.location)
            guard start != nil else { return }
            let end = txtMessage!.positionFromPosition(start!, offset: range.length)
            txtMessage!.selectedTextRange = txtMessage!.textRangeFromPosition(start!, toPosition: end!)
        }
        else{
            self.items.append((txtMessage.text)!)
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow:self.items.count - 1 , inSection:0)], withRowAnimation: .Automatic)
            txtMessage.text = ""
            textDidChange()
            txtMessage!.resignFirstResponder()
            self.showInstructionsIfNeeded()
            self.navigationItem.rightBarButtonItem = btnSave
            self.txtSubtitle.text = "\(items.count) items"
        }
    }
    
    func loadData(){
        Unifai.getDashboardItems({ items in
            self.items = items
            self.txtSubtitle.text = "\(items.count) items"
            self.tableView.reloadData()
            self.showInstructionsIfNeeded()
        })
    }
    
    func showInstructionsIfNeeded() {
        txtInstructions.hidden = items.count > 0
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableView != suggestionsTableView
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let temp = items[sourceIndexPath.row]
        items[sourceIndexPath.row] = items[destinationIndexPath.row]
        items[destinationIndexPath.row] = temp
        self.navigationItem.rightBarButtonItem = btnSave
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == suggestionsTableView ? dashboardSuggestions.count : self.items.count
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == suggestionsTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("SuggestionCell") as! SuggestionCell
            cell.txtName.text = dashboardSuggestions[indexPath.row].name
            cell.txtMessage.text = dashboardSuggestions[indexPath.row].message
            if let color = TextUtils.extractServiceColorFrom(dashboardSuggestions[indexPath.row].message) {
                cell.backgroundColor = color.darkenColor(0.03)
            }
            cell.selectionStyle = .None
            return cell
        }
        else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("DashboardEditorCell")! as! DashboardEditorCell
            cell.setMessage(self.items[indexPath.row])
            cell.backgroundColor = currentTheme.backgroundColor
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == suggestionsTableView {
            txtMessage.text = self.dashboardSuggestions[indexPath.row].message
            createOrHightlightToken()
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableView != suggestionsTableView
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete && tableView != suggestionsTableView {
            items.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.txtSubtitle.text = "\(items.count) items"
            self.showInstructionsIfNeeded()
            self.navigationItem.rightBarButtonItem = btnSave
            self.txtSubtitle.text = "\(items.count) items"
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        if txtMessage.text!.isEmpty {
            saveAndDismiss()
        }
        else {
            let alert = UIAlertController(title: "You are still writing", message: "Do you want to discard it?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Discard it", style: .Default , handler: { action in
                self.saveAndDismiss()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    func saveAndDismiss() {
        Unifai.setDashboardItems(self.items, completion: { s in
            self.dismissViewControllerAnimated(true, completion: {
                self.delegate?.didUpdateDashboardItems()
            })
        })
    }
    
    @IBAction func cancel(sender: AnyObject) {
        tableView.reloadData()
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        suggestionsView.hidden = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        suggestionsView.hidden = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !(touches.first?.view?.isKindOfClass(UITextField))! {
            view.endEditing(true)
        }
    }
}