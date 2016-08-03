import UIKit

class ActionsViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , ActionCreatorDelegate {
    
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    private let reuseIdentifier = "ActionCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    @IBOutlet weak var collectionView: UICollectionView!
    var actions : [Service:[Action]] = [:]
    var serviceOrder : [Service] = []
    
    override func viewDidLoad() {
        
        guard NSUserDefaults.standardUserDefaults().stringForKey("token") != nil else{return}
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        self.view.backgroundColor = currentTheme.backgroundColor
        self.collectionView.backgroundColor = currentTheme.backgroundColor

        self.collectionView.registerNib(UINib(nibName: "ActionCell", bundle: nil), forCellWithReuseIdentifier: "ActionCell")
        self.collectionView.registerNib(UINib(nibName: "ActionsHeader",bundle:nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")

        collectionView.delegate = self
        collectionView.dataSource = self
        
        getServicesAndUser({ _ in
            
            Unifai.getActions({ actions in
                self.setActions(actions)
                self.collectionView.reloadData()
            })
        })
        
        self.navigationItem.title = "Actions"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)! ]

    }
    
    func setActions(actions : [Action]) {
        self.actions = [:]
        self.serviceOrder = []
        for action in actions {
            if let service = extractService(action.message) {
            if !serviceOrder.contains(service) {
                serviceOrder.append(service)
            }
            if let _ = self.actions[service] {
                self.actions[service]!.append(action)
            }
            else{
                self.actions[service] = [action]
            }
            }
        }
    }
    
    func didCreateAction() {
        Unifai.getActions({ actions in
            self.setActions(actions)
            self.collectionView.reloadData()
        })
    }
    
    func deleteAction(){
        print("deleting")
    }

    
    @IBAction func create(sender: AnyObject) {
        //self.navigationController?.pushViewController(NewActionController(), animated: true)
        let creator = ActionCreatorViewController()
        creator.delegate = self
        creator.modalPresentationStyle = .Popover
        creator.popoverPresentationController!.barButtonItem = sender as? UIBarButtonItem
        
        
        creator.preferredContentSize = CGSizeMake(300,250)
        self.presentViewController(creator, animated: true, completion: nil)
    }
    
    func getServicesAndUser(callback: ([Service]) -> () ){
        if Core.Services.count > 0 {
            callback(Core.Services)
            return
        }
        Unifai.getServices({ services in
            Unifai.getUserInfo({username , email in
                Core.Username = username
                callback(services)
            })
        })
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return serviceOrder.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let service = self.serviceOrder[section]
        return (self.actions[service]?.count)!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ActionCell
        let service = serviceOrder[indexPath.section]
        cell.loadData(actions[service]![indexPath.row])
        cell.actionsViewController = self
        return cell
    }
    
    func getNumberOfCollumns() -> CGFloat {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 5 : 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width
        let cellWidth = screenWidth / getNumberOfCollumns()
        let size = CGSizeMake(cellWidth-10, 100)
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    //
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
//
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 10.0
//    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let action = self.actions[serviceOrder[indexPath.section]]![indexPath.row]
        let runner = ActionRunnerViewController()
        runner.loadAction(action)
        
        let rootVC = UINavigationController(rootViewController: runner)
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        rootVC.modalPresentationStyle = .Popover
        let viewForSource = cell
        rootVC.popoverPresentationController!.sourceView = viewForSource
        rootVC.popoverPresentationController!.sourceRect = viewForSource!.bounds
        rootVC.preferredContentSize = CGSizeMake(350,500)
        self.presentViewController(rootVC, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header =  collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) as! ActionsHeader

        let service = serviceOrder[indexPath.section]
        
        header.txtName.textColor = service.color
        header.txtCount.textColor = currentTheme.secondaryForegroundColor
        
        header.txtName.text = service.name.uppercaseString
        header.txtCount.text = String(actions[service]!.count) + " actions"
        
        return header
    }
    
    func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let item = UIMenuItem(title: "Delete", action: #selector(deleteAction))
        UIMenuController.sharedMenuController().menuItems = [item]
        
        return true
    }
    
    func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if(action == #selector(deleteAction)){
            return true
        }
        return false
    }
    
    func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        print("zzzz")
        
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    
    
}
