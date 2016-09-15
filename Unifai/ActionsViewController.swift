import UIKit

class ActionsViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , ActionCreatorDelegate {
    
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    private let reuseIdentifier = "ActionCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    @IBOutlet weak var barShadow: UIView!
    @IBOutlet weak var tutorialView: UIView!
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
        
        self.setActions(Core.Actions)
        self.collectionView.reloadData()
        
        self.navigationItem.title = "Actions"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)!, NSForegroundColorAttributeName : currentTheme.foregroundColor ]
        
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.clearColor() //Constants.appBrandColor.darkenColor(0.05)
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.translucent = true
        
        barShadow.layer.shadowPath = CGPathCreateWithRect(barShadow.bounds, nil)
        barShadow.layer.shadowColor = UIColor.blackColor().CGColor
        barShadow.layer.shadowOffset = CGSizeZero
        barShadow.layer.shadowOpacity = 0.11
        barShadow.layer.shadowRadius = 10
        barShadow.layer.borderWidth = 0
        barShadow.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.2).CGColor
    }
    
    var isFirstLoad : Bool = true
    override func viewDidAppear(animated: Bool) {
        if !isFirstLoad {
            self.setActions(Core.Actions)
            self.collectionView.reloadData()
        }
        else {
            isFirstLoad = false
        }
    }
    
    func setActions(actions : [Action]) {
        
        self.actions = [:]
        self.serviceOrder = []
        for action in actions {
            if let service = TextUtils.extractService(action.message) {
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
    
    func didCreateAction(action:Action) {
        Core.Actions.append(action)
        setActions(Core.Actions)
        collectionView.reloadData()
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if serviceOrder.count == 0 {
            tutorialView.hidden = false
        }
        else {
            tutorialView.hidden = true
        }
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
        let size = CGSizeMake(cellWidth-10, 70)
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    //
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
    
    
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
