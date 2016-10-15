import UIKit

class ActionsViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , ActionCreatorDelegate {
    
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    fileprivate let reuseIdentifier = "ActionCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    @IBOutlet weak var barShadow: UIView!
    @IBOutlet weak var tutorialView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var actions : [Service:[Action]] = [:]
    var serviceOrder : [Service] = []
    
    override func viewDidLoad() {
        
        guard UserDefaults.standard.string(forKey: "token") != nil else{return}
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        self.view.backgroundColor = currentTheme.backgroundColor
        self.collectionView.backgroundColor = currentTheme.backgroundColor

        self.collectionView.register(UINib(nibName: "ActionCell", bundle: nil), forCellWithReuseIdentifier: "ActionCell")
        self.collectionView.register(UINib(nibName: "ActionsHeader",bundle:nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")

        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.setActions(Core.Actions)
        self.collectionView.reloadData()
        
        self.navigationItem.title = "Actions"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)!, NSForegroundColorAttributeName : currentTheme.foregroundColor ]
        
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.clear //Constants.appBrandColor.darkened(amount: (0.05)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = true
        
        barShadow.layer.shadowPath = CGPath(rect: barShadow.bounds, transform: nil)
        barShadow.layer.shadowColor = UIColor.black.cgColor
        barShadow.layer.shadowOffset = CGSize.zero
        barShadow.layer.shadowOpacity = 0.11
        barShadow.layer.shadowRadius = 10
        barShadow.layer.borderWidth = 0
        barShadow.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
    }
    
    var isFirstLoad : Bool = true
    override func viewDidAppear(_ animated: Bool) {
        if !isFirstLoad {
            self.setActions(Core.Actions)
            self.collectionView.reloadData()
        }
        else {
            isFirstLoad = false
        }
    }
    
    func setActions(_ actions : [Action]) {
        
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
    
    func didCreateAction(_ action:Action) {
        Core.Actions.append(action)
        setActions(Core.Actions)
        collectionView.reloadData()
    }
    
    func deleteAction(){
        print("deleting")
    }

    
    @IBAction func create(_ sender: AnyObject) {
        //self.navigationController?.pushViewController(NewActionController(), animated: true)
        let creator = ActionCreatorViewController()
        creator.delegate = self
        creator.modalPresentationStyle = .popover
        creator.popoverPresentationController!.barButtonItem = sender as? UIBarButtonItem
        
        
        creator.preferredContentSize = CGSize(width: 300,height: 250)
        self.present(creator, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if serviceOrder.count == 0 {
            tutorialView.isHidden = false
        }
        else {
            tutorialView.isHidden = true
        }
        return serviceOrder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let service = self.serviceOrder[section]
        return (self.actions[service]?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ActionCell
        let service = serviceOrder[(indexPath as NSIndexPath).section]
        cell.loadData(actions[service]![(indexPath as NSIndexPath).row])
        cell.actionsViewController = self
        return cell
    }
    
    func getNumberOfCollumns() -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 5 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let cellWidth = screenWidth / getNumberOfCollumns()
        let size = CGSize(width: cellWidth-10, height: 70)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    //
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action = self.actions[serviceOrder[(indexPath as NSIndexPath).section]]![(indexPath as NSIndexPath).row]
        let runner = ActionRunnerViewController()
        runner.loadAction(action)
        
        let rootVC = UINavigationController(rootViewController: runner)
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        rootVC.modalPresentationStyle = .popover
        let viewForSource = cell
        rootVC.popoverPresentationController!.sourceView = viewForSource
        rootVC.popoverPresentationController!.sourceRect = viewForSource!.bounds
        rootVC.preferredContentSize = CGSize(width: 350,height: 500)
        self.present(rootVC, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! ActionsHeader

        let service = serviceOrder[(indexPath as NSIndexPath).section]
        
        header.txtName.textColor = service.color
        header.txtCount.textColor = currentTheme.secondaryForegroundColor
        
        header.txtName.text = service.name.uppercased()
        header.txtCount.text = String(actions[service]!.count) + " actions"
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        let item = UIMenuItem(title: "Delete", action: #selector(deleteAction))
        UIMenuController.shared.menuItems = [item]
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if(action == #selector(deleteAction)){
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        print("zzzz")
        
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    
    
    
    
}
