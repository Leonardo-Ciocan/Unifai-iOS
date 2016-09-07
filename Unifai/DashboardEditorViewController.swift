import UIKit

protocol DashboardEditorViewControllerDelegate {
    func didUpdateDashboardItems()
}

class DashboardEditorViewController: UIViewController , UITableViewDataSource , UITableViewDelegate, UITextFieldDelegate{

    @IBOutlet
    var tableView: UITableView!
    
    var items : [String] = []
    var header : DashboardEditorHeader?
    var delegate : DashboardEditorViewControllerDelegate?
    
    @IBOutlet weak var txtInstructions: UILabel!
    let txtTitle = UILabel()
    let txtSubtitle = UILabel()
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
        header = DashboardEditorHeader(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45))
        self.tableView.tableHeaderView = header
        self.header?.txtMessage.delegate = self
        
        txtTitle.text = "Editing dashboard"
        txtTitle.font = txtTitle.font.fontWithSize(13)
        txtSubtitle.text = "Loading..."
        txtTitle.textColor = UIColor.whiteColor()
        txtSubtitle.textColor = UIColor.whiteColor()
        txtSubtitle.font = txtSubtitle.font.fontWithSize(13)
        txtTitle.textAlignment = .Center
        txtSubtitle.textAlignment = .Center
        
        let titleContainer = UIStackView(arrangedSubviews: [txtTitle, txtSubtitle])
        titleContainer.axis = .Vertical
        titleContainer.frame = CGRect(x: 0, y: 0, width: 200, height: 33)
        navigationItem.titleView = titleContainer
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = Constants.appBrandColor
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.translucent = false
        

        loadData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.items.append((header?.txtMessage.text)!)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow:self.items.count - 1 , inSection:0)], withRowAnimation: .Automatic)
        header?.txtMessage.text = ""
        textField.resignFirstResponder()
        self.showInstructionsIfNeeded()
        return false
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
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let temp = items[sourceIndexPath.row]
        items[sourceIndexPath.row] = items[destinationIndexPath.row]
        items[destinationIndexPath.row] = temp
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("DashboardEditorCell")! as! DashboardEditorCell
        cell.setMessage(self.items[indexPath.row])
        cell.backgroundColor = currentTheme.backgroundColor
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            items.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.txtSubtitle.text = "\(items.count) items"
            self.showInstructionsIfNeeded()
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        if header!.txtMessage.text!.isEmpty {
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}