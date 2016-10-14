import UIKit
import SafariServices

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
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 115, left: 5, bottom: 10, right: 5)
        collectionView.collectionViewLayout = layout
        
        collectionView.backgroundColor = currentTheme.backgroundColor
        collectionView.register(UINib(nibName: "SheetCell", bundle: nil), forCellWithReuseIdentifier: "SheetCell")
        collectionView.register(UINib(nibName: "SheetsViewHeader", bundle: nil), forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "header")
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(doneTapped))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: #selector(filterTapped))
//        
        //textboxShadow.backgroundColor = UIColor.whiteColor()
        textboxShadow.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.04).cgColor
        textboxShadow.layer.borderWidth = 0
        //textboxBlur.hidden = true
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        txtSearch.leftViewMode = .always
        txtSearch.leftView = leftView
        
        txtSearch.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.03)
        
        txtSearch.delegate = self
        txtSearch.clipsToBounds = true
        let rightBorder: CALayer = CALayer()
        rightBorder.borderColor = UIColor.black.withAlphaComponent(0.09).cgColor
        rightBorder.borderWidth = 1
        rightBorder.frame = CGRect(x: 0, y: txtSearch.frame.height - 0.6, width: txtSearch.frame.width, height: 0.6)
        txtSearch.layer.addSublayer(rightBorder)
        self.txtItemsTitle.text = String(self.sheets.count) + " items"
        txtSearch.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        searchSuggestions.delegate = self
    }
    
    func didSelectSuggestion(_ text: String) {
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
    
    func textDoesEndWithEmptyExpression(_ text:String) -> Bool {
        let component = text.components(separatedBy: ",")[0].trim()
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
    
    func generateFilterBlocksFromText(_ text:String) -> [FilterType] {
        let components = text.components(separatedBy: ",")
        var blocks : [FilterType] = []
        for component in components {
            let filter = FilterType.fromText(component)
            if FilterType.none == filter {
            
            } else {
                blocks.append(filter)
            }
        }
        return blocks
    }
    
    func doesStartWith(_ sheet:Sheet, key:String, value:String) -> Bool {
        for entry in sheet.entries {
            switch entry {
            case let entry as TextSheetEntry:
                if (key == "name" || key == "title") && entry.text.lowercased().hasPrefix(value) {
                    return true
                }
            case let entry as TitledSheetEntry:
                if entry.title.lowercased() == key.lowercased() {
                    return entry.subtitle.lowercased().hasPrefix(value.lowercased())
                }
            default:
                continue
            }
        }
        return false
    }
    
    func doesContain(_ sheet:Sheet, key:String, value:String) -> Bool {
        for entry in sheet.entries {
            switch entry {
            case let entry as TextSheetEntry:
                if (key == "name" || key == "title") && entry.text.lowercased().contains(value) {
                    return true
                }
            case let entry as TitledSheetEntry:
                if entry.title.lowercased() == key.lowercased() {
                    return entry.subtitle.lowercased().contains(value.lowercased())
                }
            default:
                continue
            }
        }
        return false
    }
    
    func isMoreThan(_ sheet:Sheet, key:String, value:Int) -> Bool {
        for entry in sheet.entries {
            switch entry {
            case let entry as TitledSheetEntry:
                if entry.title.lowercased() == key.lowercased() {
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
    
    func isLessThan(_ sheet:Sheet, key:String, value:Int) -> Bool {
        for entry in sheet.entries {
            switch entry {
            case let entry as TitledSheetEntry:
                if entry.title.lowercased() == key.lowercased() {
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


    
    func executeFilterBlocks(_ filters : [FilterType]) -> [Sheet] {
        var newFilteredSheets = self.sheets
        for filter in filters {
            switch filter {
            case .startsWith(key: let key, value: let value):
                newFilteredSheets = newFilteredSheets.filter { doesStartWith($0, key: key, value: value) }
            case .contains(key: let key, value: let value):
                newFilteredSheets = newFilteredSheets.filter { doesContain($0, key: key, value: value) }
            case .moreThan(key: let key, value: let value):
                newFilteredSheets = newFilteredSheets.filter { isMoreThan($0, key: key, value: value) }
            case .lessThan(key: let key, value: let value):
                newFilteredSheets = newFilteredSheets.filter { isLessThan($0, key: key, value: value) }
            default:
                continue
            }
        }
        return newFilteredSheets
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textboxHeightConstraint.constant = 120
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
            },completion: { _ in
                UIView.animate(withDuration: 0.3, animations: { self.searchSuggestions.alpha = 1 })
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchSuggestions.alpha = 0
            },completion : { _ in
                self.textboxHeightConstraint.constant = 80
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                })
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        txtSearch.resignFirstResponder()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        txtSearch.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        textboxShadow.layer.shadowPath = CGPath(rect: textboxShadow.bounds, transform: nil)
        textboxShadow.layer.shadowColor = UIColor.black.cgColor
        textboxShadow.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        textboxShadow.layer.shadowOpacity = 0.15
        textboxShadow.layer.shadowRadius = 8
    }
    
    func filterTapped() {
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredSheets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SheetCell", for: indexPath) as! SheetCell
        cell.service = self.service
        cell.loadEntries(filteredSheets[(indexPath as NSIndexPath).row].entries)
        cell.backgroundColor = service?.color
        cell.delegate = self
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width / 2 - 7.5, height: self.itemHeight)
    }
    
    var sheetFields : [String] = []
    func loadSheets(_ sheets:[Sheet],service:Service?,itemHeight:CGFloat) {
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
                return entry.title.lowercased()
            default:
                return nil
            }
        }
        
        searchSuggestions.setSuggestions(SheetSearchSuggestionItem.computeSuggestionsForText(sheetFields, text: "")
, forService: service!)
    }
    
    func shouldOpenLinkWithURL(_ url: String) {
        let svc = SFSafariViewController(url: URL(string: url)!)
        self.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func tappedFilter(_ sender: AnyObject) {
        
    }
    
    @IBAction func doneTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func shouldSendMessageWithText(_ text: String, sourceRect: CGRect, sourceView: UIView) {
        let runner = ActionRunnerViewController()
        runner.loadAction(Action(message: text, name: ""))
        
        let rootVC = UINavigationController(rootViewController: runner)
        rootVC.modalPresentationStyle = .popover
        rootVC.popoverPresentationController!.sourceView = sourceView
        rootVC.popoverPresentationController!.sourceRect = sourceRect
        rootVC.preferredContentSize = CGSize(width: 350,height: 500)
        self.present(rootVC, animated: true, completion: nil)
    }
}
