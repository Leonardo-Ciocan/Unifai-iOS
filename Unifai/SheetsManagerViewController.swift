import UIKit

class SheetsManagerViewController: UIViewController, SheetCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {

    var sheets : [Sheet] = []
    var filteredSheets : [Sheet] = []
    var service : Service?
    var itemHeight : CGFloat = 0
    
    @IBOutlet weak var textboxHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textboxShadow: UIView!
    @IBOutlet weak var textboxBlur: UIVisualEffectView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var txtItemsTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .Vertical
        layout.sectionInset = UIEdgeInsets(top: 70, left: 5, bottom: 10, right: 5)
        collectionView.collectionViewLayout = layout
        
        collectionView.backgroundColor = currentTheme.backgroundColor
        collectionView.registerNib(UINib(nibName: "SheetCell", bundle: nil), forCellWithReuseIdentifier: "SheetCell")
        collectionView.registerNib(UINib(nibName: "SheetsViewHeader", bundle: nil), forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "header")
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(doneTapped))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: #selector(filterTapped))
//        
        textboxShadow.backgroundColor = UIColor.whiteColor()
        textboxShadow.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.04).CGColor
        textboxShadow.layer.borderWidth = 1
        textboxBlur.hidden = true
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        txtSearch.leftViewMode = .Always
        txtSearch.leftView = leftView
        
        txtSearch.delegate = self
        txtSearch.clipsToBounds = true
        let rightBorder: CALayer = CALayer()
        rightBorder.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.09).CGColor
        rightBorder.borderWidth = 1
        rightBorder.frame = CGRectMake(0, 0, CGRectGetWidth(txtSearch.frame), 0.6)
        txtSearch.layer.addSublayer(rightBorder)
        self.txtItemsTitle.text = String(self.sheets.count) + " items"
        txtSearch.addTarget(self, action: #selector(textChanged), forControlEvents: .EditingChanged)
    }
    
    func textChanged(){
        let blocks = generateFilterBlocksFromText(txtSearch.text!)
        let filtered = executeFilterBlocks(blocks)
        self.filteredSheets = filtered
        self.txtItemsTitle.text = String(self.sheets.count) + " items"
        self.collectionView.reloadData()
    }
    
    func generateFilterBlocksFromText(text:String) -> [FilterType] {
        let components = text.componentsSeparatedByString(",")
        var blocks : [FilterType] = []
        for component in components {
            let filter = FilterType.fromText(component)
            if FilterType.None == filter {
            
            } else {
                blocks.append(filter)
            }
        }
        return blocks
    }
    
    func doesStartWith(sheet:Sheet, key:String, value:String) -> Bool {
        for entry in sheet.entries {
            switch entry {
            case let entry as TextSheetEntry:
                if (key == "name" || key == "title") && entry.text.lowercaseString.hasPrefix(value) {
                    return true
                }
            case let entry as TitledSheetEntry:
                if entry.title.lowercaseString == key.lowercaseString {
                    return entry.subtitle.lowercaseString.hasPrefix(value.lowercaseString)
                }
            default:
                continue
            }
        }
        return false
    }
    
    func doesContain(sheet:Sheet, key:String, value:String) -> Bool {
        for entry in sheet.entries {
            switch entry {
            case let entry as TextSheetEntry:
                if (key == "name" || key == "title") && entry.text.lowercaseString.containsString(value) {
                    return true
                }
            case let entry as TitledSheetEntry:
                if entry.title.lowercaseString == key.lowercaseString {
                    return entry.subtitle.lowercaseString.containsString(value.lowercaseString)
                }
            default:
                continue
            }
        }
        return false
    }

    
    func executeFilterBlocks(filters : [FilterType]) -> [Sheet] {
        var newFilteredSheets = self.sheets
        for filter in filters {
            switch filter {
            case .StartsWith(key: let key, value: let value):
                newFilteredSheets = newFilteredSheets.filter { doesStartWith($0, key: key, value: value) }
            case .Contains(key: let key, value: let value):
                newFilteredSheets = newFilteredSheets.filter { doesContain($0, key: key, value: value) }
            default:
                continue
            }
        }
        return newFilteredSheets
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textboxHeightConstraint.constant = 105
        UIView.animateWithDuration(0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textboxHeightConstraint.constant = 70
        UIView.animateWithDuration(0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        txtSearch.resignFirstResponder()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        txtSearch.resignFirstResponder()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func viewDidLayoutSubviews() {
        textboxShadow.layer.shadowColor = UIColor.blackColor().CGColor
        textboxShadow.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        textboxShadow.layer.shadowOpacity = 0.18
        textboxShadow.layer.shadowRadius = 2
    }
    
    func filterTapped() {
        
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredSheets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SheetCell", forIndexPath: indexPath) as! SheetCell
        cell.service = self.service
        cell.loadEntries(filteredSheets[indexPath.row].entries)
        cell.backgroundColor = service?.color
        cell.delegate = self
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width / 2 - 7.5, height: self.itemHeight)
    }
    
    func loadSheets(sheets:[Sheet],service:Service?,itemHeight:CGFloat) {
        self.sheets = sheets
        self.filteredSheets = sheets
        self.service = service
        self.itemHeight = itemHeight
        self.view.tintColor = service?.color
        self.navigationController?.navigationBar.tintColor = service?.color
    }
    
    func shouldOpenLinkWithURL(url: String) {
        
    }
    
    @IBAction func tappedFilter(sender: AnyObject) {
        
    }
    
    @IBAction func doneTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shouldSendMessageWithText(text: String, sourceRect: CGRect, sourceView: UIView) {
        
    }
}
