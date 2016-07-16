import UIKit

class ActionsViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , ActionCreatorDelegate {
    
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    private let reuseIdentifier = "ActionCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    @IBOutlet weak var collectionView: UICollectionView!
    var actions : [Action] = []
    
    override func viewDidLoad() {
        
        guard NSUserDefaults.standardUserDefaults().stringForKey("token") != nil else{return}
        self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
        self.view.backgroundColor = currentTheme.backgroundColor
        self.collectionView.backgroundColor = currentTheme.backgroundColor

        self.collectionView.registerNib(UINib(nibName: "ActionCell", bundle: nil), forCellWithReuseIdentifier: "ActionCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        getServicesAndUser({ _ in
            
            Unifai.getActions({ actions in
                self.actions = actions
                self.collectionView.reloadData()
            })
        })
        
        self.navigationItem.title = "Actions"
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName : UIFont(name:"Helvetica",size:15)! ]

    }
    
    func deleteAction(){
        print("deleting")
    }

    
    @IBAction func create(sender: AnyObject) {
        //self.navigationController?.pushViewController(NewActionController(), animated: true)
        let creator = ActionCreatorViewController()
        creator.delegate = self
        self.presentViewController(creator, animated: true, completion: nil)
    }
    
    func createAction(name: String, message: String) {
        Unifai.createAction(message, name: name, completion: { _ in
            Unifai.getActions({ actions in
                self.actions = actions
                self.collectionView.reloadData()
            })
        })
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
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ActionCell
        //cell.backgroundColor = UIColor.redColor()
        cell.loadData(actions[indexPath.row])
        cell.actionsViewController = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width
        let cellWidth = screenWidth / 2.0
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
        
        navigationController?.navigationBar.barStyle = .Black
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)!
        let cellFrame = collectionView.convertRect(cell.frame, toView: self.view)
        let frame = CGRect(origin: CGPoint(x:cellFrame.origin.x ,y:cellFrame.origin.y ), size: cellFrame.size)
        let window = UIApplication.sharedApplication().keyWindow
        
        let effectView = ActionRunnerPage(frame: UIScreen.mainScreen().bounds)
        effectView.hidden = true
        let serviceColor = extractServiceColorFrom(self.actions[indexPath.row].message)
        effectView.colorView.backgroundColor = serviceColor
        effectView.layer.masksToBounds = true
        window?.addSubview(effectView)
        
        let effectMaskView = UIView(frame:UIScreen.mainScreen().bounds)
        let effectMaskViewChild = UIView(frame:frame)
        effectMaskView.addSubview(effectMaskViewChild)
        //effectView.addSubview(effectMaskView)
        effectMaskViewChild.backgroundColor = UIColor.whiteColor()
        effectView.backgroundColor = serviceColor
        effectView.maskView = effectMaskView
        effectMaskViewChild.layer.cornerRadius = 300

        let service = extractService(self.actions[indexPath.row].message)
        effectView.imgLogo.image = UIImage(named: service!.username)

        let actionMessage = Message(body: self.actions[indexPath.row].message , type: .Text, payload: nil)
        effectView.messages.append(actionMessage)
        effectView.tableView.reloadData()
        
        //effectView.alpha = 0
        effectView.tableView.alpha = 0
        effectView.hidden = false
        
        effectView.tableView.transform = CGAffineTransformMakeTranslation(0, 35)
        
        effectView.btnKeepHandler = {
            self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
            let targetFrame = effectView.convertRect(effectView.btnKeep.frame, toView: nil)
            UIView.animateWithDuration(0.35, delay: 0, options: .CurveEaseIn, animations: {
                    effectMaskViewChild.frame = targetFrame
                    effectView.alpha = 0

                }, completion: { _ in
                    effectView.removeFromSuperview()
            })
        }
        
        effectView.btnDiscardHandler = {
            Unifai.deleteThread(effectView.message!.threadID!, completion: nil)
            self.navigationController?.navigationBar.barStyle = currentTheme.barStyle
            let targetFrame = effectView.convertRect(effectView.btnDiscard.frame, toView: nil)
            UIView.animateWithDuration(0.35, delay: 0, options: .CurveEaseIn, animations: {
                effectMaskViewChild.frame = targetFrame
                effectView.alpha = 0
                }, completion: { _ in
                    effectView.removeFromSuperview()
            })
        }
        
        effectMaskView.userInteractionEnabled = false
        
        UIView.animateWithDuration(0.35, delay: 0, options: .CurveEaseOut, animations: {
                effectMaskViewChild.frame = UIScreen.mainScreen().bounds
                //effectView.alpha = 1
                effectMaskViewChild.layer.cornerRadius = 0

            }, completion: { _ in
                UIView.animateWithDuration(0.3, delay: 0.35, options: .CurveEaseOut, animations: {
                    effectView.tableView.alpha = 1
                    effectView.backgroundColor = UIColor.whiteColor()
                    effectView.tableView.transform = CGAffineTransformMakeTranslation(0, 0)
                    }, completion: { _ in
                        
                })
        })
        
        Unifai.runAction(self.actions[indexPath.row], completion: { msg in
            effectView.message = msg
            effectView.messages.append(msg)
            effectView.tableView.reloadData()
            effectView.activityIndicator.stopAnimating()
        })
        
//        Unifai.sendMessage(actions[indexPath.row].message, completion: { _ in
//                //((self.tabBarController?.viewControllers?.first as! MainSplitView).viewControllers.first as! FeedViewController).loadData()
//                self.tabBarController?.selectedIndex = 0
//        })
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
