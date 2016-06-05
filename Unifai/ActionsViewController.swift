import UIKit

class ActionsViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    private let reuseIdentifier = "ActionCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    @IBOutlet weak var collectionView: UICollectionView!
    var actions : [Action] = []
    
    override func viewDidLoad() {
        
        guard NSUserDefaults.standardUserDefaults().stringForKey("token") != nil else{return}
        
        self.collectionView.registerNib(UINib(nibName: "ActionCell", bundle: nil), forCellWithReuseIdentifier: "ActionCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        Unifai.getActions({ actions in
            self.actions = actions
            self.collectionView.reloadData()
        })
        self.navigationItem.title = "Actions"
    }
    
    
    @IBAction func create(sender: AnyObject) {
        self.navigationController?.pushViewController(NewActionController(), animated: true)
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
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width
        let cellWidth = screenWidth / 2.0
        let size = CGSizeMake(cellWidth-10, cellWidth-10)
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
        Unifai.sendMessage(actions[indexPath.row].message, completion: { _ in
                //((self.tabBarController?.viewControllers?.first as! MainSplitView).viewControllers.first as! FeedViewController).loadData()
                self.tabBarController?.selectedIndex = 0
        })
    }
    
}
