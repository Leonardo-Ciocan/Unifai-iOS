import UIKit

class ActionsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource  {
    @IBOutlet weak var tableView: UITableView!
    
    var actions : [Action] = []
    
    override func viewDidLoad() {
        self.tableView!.registerNib(UINib(nibName: "ActionCell", bundle: nil), forCellReuseIdentifier: "ActionCell")
        
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 120
        self.tableView!.tableFooterView = UIView()
        self.tableView!.separatorStyle = .None
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        guard NSUserDefaults.standardUserDefaults().stringForKey("token") != nil else{return}
        
        loadData()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
        
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 33, height: 33))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "logo")
        imageView.image = image
        navigationItem.titleView = imageView
    }
    
    override func viewDidAppear(animated: Bool) {
       // loadData()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    
    func loadData(){
        //this is a feed view
        Unifai.getActions({ actions in
            print(actions.count)
            self.actions = actions
            self.tableView?.reloadData()
        })
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Unifai.sendMessage(self.actions[indexPath.row].message, completion: { _ in
            self.tabBarController?.selectedIndex = 0
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ActionCell") as! ActionCell
        cell.loadData(self.actions[indexPath.row])
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    @IBAction func create(sender: AnyObject) {
        self.presentViewController(NewActionController(), animated: true, completion: {
            _ in
            self.loadData()
            
        })
    }
    
}
