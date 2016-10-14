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
        self.tableView.isEditing = true
        self.tableView.register(UINib(nibName: "DashboardEditorCell", bundle: nil), forCellReuseIdentifier: "DashboardEditorCell")
        self.tableView.tableFooterView = UIView()
        self.txtMessage.delegate = self
        
        txtTitle.text = "Editing dashboard"
        txtTitle.font = txtTitle.font.withSize(13)
        txtSubtitle.text = "Loading..."
        txtTitle.textColor = UIColor.gray
        txtSubtitle.textColor = UIColor.gray
        txtSubtitle.font = txtSubtitle.font.withSize(13)
        txtTitle.textAlignment = .center
        txtSubtitle.textAlignment = .center
        
        let titleContainer = UIStackView(arrangedSubviews: [txtTitle, txtSubtitle])
        titleContainer.axis = .vertical
        titleContainer.frame = CGRect(x: 0, y: 0, width: 200, height: 33)
        navigationItem.titleView = titleContainer
        
        self.btnSave = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(done))
        self.navigationItem.rightBarButtonItem = nil
        loadData()
        
        self.allSuggestions = Core.Catalog.values.flatMap({ $0 }).filter({ $0.isSuitableForDashboard })
        self.dashboardSuggestions = Core.Catalog.values.flatMap({ $0 }).filter({ $0.isSuitableForDashboard })
        
        self.suggestionsTableView.register(UINib(nibName: "SuggestionCell",bundle: nil), forCellReuseIdentifier: "SuggestionCell")
        self.suggestionsTableView.dataSource = self
        self.suggestionsTableView.delegate = self
        self.suggestionsTableView!.rowHeight = UITableViewAutomaticDimension
        self.suggestionsTableView.estimatedRowHeight = 100
        self.suggestionsTableView.separatorColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.suggestionsTableView.separatorInset = UIEdgeInsets.zero
        self.suggestionsTableView.separatorStyle = .none
        self.suggestionsTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 64 + 40))
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.clear //Constants.appBrandColor.darkenColor(0.05)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = true
        
        barShadow.layer.shadowPath = CGPath(rect: barShadow.bounds, transform: nil)
        barShadow.layer.shadowColor = UIColor.black.cgColor
        barShadow.layer.shadowOffset = CGSize.zero
        barShadow.layer.shadowOpacity = 0.15
        barShadow.layer.shadowRadius = 5
        barShadow.layer.borderWidth = 0
        barShadow.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        
        txtMessage.textColor = UIColor.black
        txtMessage.layer.masksToBounds = true
        txtMessage.tintColor = UIColor.black
        
        
        
        txtMessage.attributedPlaceholder = NSAttributedString(string: "Enter any message..." ,
                                                              attributes:[NSForegroundColorAttributeName: UIColor.gray])
        
        
        txtMessage.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        txtMessage.leftViewMode = .always
        txtMessage.leftView = leftView
        
        txtMessage.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )
        
        registerForKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.suggestionsBottomConstraint.constant = keyboardSize.height
            self.tableViewBottomConstraint.constant = keyboardSize.height
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.suggestionsBottomConstraint.constant = 0
        self.tableViewBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func textDidChange() {
        let text = txtMessage.text
        let wordsInQuery = (text!.components(separatedBy: " "))
        var filtered : [CatalogItem] = self.allSuggestions
            wordsInQuery.forEach({ keyword in
                filtered = filtered.filter({
                    $0.name.lowercased().contains(keyword.lowercased()) ||
                        $0.message.lowercased().contains(keyword.lowercased()) ||
                        keyword == ""
                })
            })
        self.dashboardSuggestions = filtered
        self.suggestionsTableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createOrHightlightToken()
        return false
    }
    
    func createOrHightlightToken() {
        let placeholderRanges = TextUtils.getPlaceholderPositionsInMessage((txtMessage?.text)!)
        if placeholderRanges.count > 0 {
            let range = placeholderRanges[0]
            let start = txtMessage!.position(from: txtMessage!.beginningOfDocument, offset: range.location)
            guard start != nil else { return }
            let end = txtMessage!.position(from: start!, offset: range.length)
            txtMessage!.selectedTextRange = txtMessage!.textRange(from: start!, to: end!)
        }
        else{
            self.items.append((txtMessage.text)!)
            tableView.insertRows(at: [IndexPath(row:self.items.count - 1 , section:0)], with: .automatic)
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
        txtInstructions.isHidden = items.count > 0
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return tableView != suggestionsTableView
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = items[(sourceIndexPath as NSIndexPath).row]
        items[(sourceIndexPath as NSIndexPath).row] = items[(destinationIndexPath as NSIndexPath).row]
        items[(destinationIndexPath as NSIndexPath).row] = temp
        self.navigationItem.rightBarButtonItem = btnSave
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == suggestionsTableView ? dashboardSuggestions.count : self.items.count
    }
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == suggestionsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell") as! SuggestionCell
            cell.txtName.text = dashboardSuggestions[(indexPath as NSIndexPath).row].name
            cell.txtMessage.text = dashboardSuggestions[(indexPath as NSIndexPath).row].message
            if let color = TextUtils.extractServiceColorFrom(dashboardSuggestions[(indexPath as NSIndexPath).row].message) {
                cell.backgroundColor = color.darkenColor(0.03)
            }
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "DashboardEditorCell")! as! DashboardEditorCell
            cell.setMessage(self.items[(indexPath as NSIndexPath).row])
            cell.backgroundColor = currentTheme.backgroundColor
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == suggestionsTableView {
            txtMessage.text = self.dashboardSuggestions[(indexPath as NSIndexPath).row].message
            createOrHightlightToken()
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView != suggestionsTableView
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && tableView != suggestionsTableView {
            items.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.txtSubtitle.text = "\(items.count) items"
            self.showInstructionsIfNeeded()
            self.navigationItem.rightBarButtonItem = btnSave
            self.txtSubtitle.text = "\(items.count) items"
        }
    }
    
    @IBAction func done(_ sender: AnyObject) {
        if txtMessage.text!.isEmpty {
            saveAndDismiss()
        }
        else {
            let alert = UIAlertController(title: "You are still writing", message: "Do you want to discard it?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Discard it", style: .default , handler: { action in
                self.saveAndDismiss()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func saveAndDismiss() {
        Unifai.setDashboardItems(self.items, completion: { s in
            self.dismiss(animated: true, completion: {
                self.delegate?.didUpdateDashboardItems()
            })
        })
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        tableView.reloadData()
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        suggestionsView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        suggestionsView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !(touches.first?.view?.isKind(of: UITextField.self))! {
            view.endEditing(true)
        }
    }
}
