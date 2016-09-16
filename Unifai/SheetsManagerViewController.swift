import UIKit

class SheetsManagerViewController: UIViewController, SheetCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, SheetsManagerSuggestionsViewDelegate {

    var sheets : [Sheet] = []
    var filteredSheets : [Sheet] = []
    var service : Service?
    var itemHeight : CGFloat = 0
    
    @IBOutlet weak var searchSuggestions: SheetsManagerSuggestionsView!
    @IBOutlet weak var textboxHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textboxShadow: UIView!
    @IBOutlet weak var textboxBlur: UIVisualEffectView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var txtItemsTitle: UILabel!
    let layout = UICollectionViewFlowLayout()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .Vertical
        layout.sectionInset = UIEdgeInsets(top: 115, left: 5, bottom: 10, right: 5)
        collectionView.collectionViewLayout = layout
        
        collectionView.backgroundColor = currentTheme.backgroundColor
        collectionView.registerNib(UINib(nibName: "SheetCell", bundle: nil), forCellWithReuseIdentifier: "SheetCell")
        collectionView.registerNib(UINib(nibName: "SheetsViewHeader", bundle: nil), forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "header")
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(doneTapped))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: #selector(filterTapped))
//        
        //textboxShadow.backgroundColor = UIColor.whiteColor()
        textboxShadow.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.04).CGColor
        textboxShadow.layer.borderWidth = 0
        //textboxBlur.hidden = true
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        txtSearch.leftViewMode = .Always
        txtSearch.leftView = leftView
        
        txtSearch.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.03)
        
        txtSearch.delegate = self
        txtSearch.clipsToBounds = true
        let rightBorder: CALayer = CALayer()
        rightBorder.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.09).CGColor
        rightBorder.borderWidth = 1
        rightBorder.frame = CGRectMake(0, CGRectGetHeight(txtSearch.frame) - 0.6, CGRectGetWidth(txtSearch.frame), 0.6)
        txtSearch.layer.addSublayer(rightBorder)
        self.txtItemsTitle.text = String(self.sheets.count) + " items"
        txtSearch.addTarget(self, action: #selector(textChanged), forControlEvents: .EditingChanged)
        searchSuggestions.delegate = self
    }
    
    func didSelectSuggestion(text: String) {
        txtSearch.text = txtSearch.text!.isEmpty ? text :  (txtSearch.text! + " " + text)
        textChanged()
    }
    
    func textChanged(){
        let blocks = generateFilterBlocksFromText(txtSearch.text!)
        let filtered = executeFilterBlocks(blocks)
        self.filteredSheets = filtered
        self.txtItemsTitle.text = String(self.filteredSheets.count) + " items"
        self.collectionView.reloadData()
        highlightKeywords()
        populateSuggestions()
    }
    
    func populateSuggestions() {
        searchSuggestions.setSuggestions(SheetSearchSuggestionItem.computeSuggestionsForText(
            sheetFields,
            text: txtSearch.text!), forService: service!)
    }
    
    func textDoesEndWithEmptyExpression(text:String) -> Bool {
        let component = text.componentsSeparatedByString(",")[0].trim()
        return component.isEmpty
    }
    
    
    
    let keywords = ["is","contains","more than","less than"]
    func highlightKeywords() {
        if let text = txtSearch.text {
            let cursorPosition = txtSearch.selectedTextRange
            let attributedString = NSMutableAttributedString(string: text)
            for keyword in keywords {
                let matches = ("(\\s|^)" + keyword + "(\\s|$)").r!.findAll(in: text)
                for match in matches {
                    let range = match.range
                    let start = text.startIndex.distance(to: range.startIndex)
                    let lenght = text.startIndex.distance(to: range.endIndex) - start
                    attributedString.addAttributes([NSForegroundColorAttributeName: (service?.color)!],
                                                   range: NSMakeRange(start, lenght))
                }
            }
            txtSearch.attributedText = attributedString
            txtSearch.selectedTextRange = cursorPosition
        }
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
    
    func isMoreThan(sheet:Sheet, key:String, value:Int) -> Bool {
        for entry in sheet.entries {
            switch entry {
            case let entry as TitledSheetEntry:
                if entry.title.lowercaseString == key.lowercaseString {
                    if let entryValue = Int(entry.subtitle) {
                        return entryValue > value
                    }
                }
            default:
                continue
            }
        }
        return false
    }
    
    func isLessThan(sheet:Sheet, key:String, value:Int) -> Bool {
        for entry in sheet.entries {
            switch entry {
            case let entry as TitledSheetEntry:
                if entry.title.lowercaseString == key.lowercaseString {
                    if let entryValue = Int(entry.subtitle) {
                        return entryValue < value
                    }
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
            case .MoreThan(key: let key, value: let value):
                newFilteredSheets = newFilteredSheets.filter { isMoreThan($0, key: key, value: value) }
            case .LessThan(key: let key, value: let value):
                newFilteredSheets = newFilteredSheets.filter { isLessThan($0, key: key, value: value) }
            default:
                continue
            }
        }
        return newFilteredSheets
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textboxHeightConstraint.constant = 120
        UIView.animateWithDuration(0.5, animations: {
            self.view.layoutIfNeeded()
            },completion: { _ in
                UIView.animateWithDuration(0.3, animations: { self.searchSuggestions.alpha = 1 })
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        UIView.animateWithDuration(0.3, animations: {
            self.searchSuggestions.alpha = 0
            },completion : { _ in
                self.textboxHeightConstraint.constant = 80
                UIView.animateWithDuration(0.5, animations: {
                    self.view.layoutIfNeeded()
                })
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
    
    override func viewDidLayoutSubviews() {
        textboxShadow.layer.shadowPath = CGPathCreateWithRect(textboxShadow.bounds, nil)
        textboxShadow.layer.shadowColor = UIColor.blackColor().CGColor
        textboxShadow.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        textboxShadow.layer.shadowOpacity = 0.15
        textboxShadow.layer.shadowRadius = 8
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
    
    var sheetFields : [String] = []
    func loadSheets(sheets:[Sheet],service:Service?,itemHeight:CGFloat) {
        self.sheets = sheets
        self.filteredSheets = sheets
        self.service = service
        self.itemHeight = itemHeight
        self.view.tintColor = service?.color
        self.navigationController?.navigationBar.tintColor = service?.color
        sheetFields = sheets.first!.entries.flatMap{ entry in
            switch entry  {
            case let _ as TextSheetEntry:
                return "title"
            case let entry as TitledSheetEntry:
                return entry.title.lowercaseString
            default:
                return nil
            }
        }
        
        searchSuggestions.setSuggestions(SheetSearchSuggestionItem.computeSuggestionsForText(sheetFields, text: "")
, forService: service!)
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
