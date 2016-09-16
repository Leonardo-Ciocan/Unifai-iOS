import Foundation
import UIKit

struct SheetSearchSuggestionItem {
    let label : String
    let isField : Bool
    
    static func computeSuggestionsForText(fields:[String], text:String) -> [SheetSearchSuggestionItem] {
        let lastComponent = text.componentsSeparatedByString(",").last!
        print(lastComponent)
        if lastComponent.isEmpty {
            var initial : [SheetSearchSuggestionItem] =  ["more than","less than"].map {
                SheetSearchSuggestionItem(label: $0, isField: false)
            }
            initial.appendContentsOf(fields.map { SheetSearchSuggestionItem(label: $0, isField: true)})
            return initial
        }
        else if "(more|less) than (\\d+\\.?\\d*) $".r!.matches( lastComponent ){
            return fields.map({ SheetSearchSuggestionItem(label:$0, isField: true) })
        }
        
        return [
            SheetSearchSuggestionItem(label: "is", isField: false),
            SheetSearchSuggestionItem(label: ",", isField: false),
        ]
    }
}

protocol SheetsManagerSuggestionsViewDelegate {
    func didSelectSuggestion(text:String)
}

class SheetsManagerSuggestionsView : UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var items : [SheetSearchSuggestionItem] = [
        SheetSearchSuggestionItem(label: "stars",isField: true),
        SheetSearchSuggestionItem(label: "is",isField: false),
        SheetSearchSuggestionItem(label: "title",isField: true),
        SheetSearchSuggestionItem(label: "more than",isField: false),
        SheetSearchSuggestionItem(label: "less than",isField: false),
        SheetSearchSuggestionItem(label: "contains",isField: false),
    ]
    
    var service : Service?
    var delegate : SheetsManagerSuggestionsViewDelegate?
    
    let layout = UICollectionViewFlowLayout()
    let collectionView : UICollectionView?

    required init?(coder aDecoder: NSCoder) {
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        super.init(coder: aDecoder)
        collectionView!.registerNib(UINib(nibName: "SheetSearchSuggestionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        layout.estimatedItemSize = CGSize(width: 100, height: 40)
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        self.addSubview(collectionView!)
        collectionView!.snp_makeConstraints(closure: { make in
            make.leading.trailing.bottom.top.equalTo(self)
        })
        collectionView!.showsVerticalScrollIndicator = false
        collectionView!.showsHorizontalScrollIndicator = false
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.backgroundColor = UIColor.clearColor()
    }
    
    func setSuggestions(suggestions:[SheetSearchSuggestionItem], forService service:Service) {
        self.items = suggestions
        self.service = service
        self.collectionView!.reloadData()
    }
    
    static let regularFont = UIFont.systemFontOfSize(15)
    static let boldFont = UIFont.boldSystemFontOfSize(15)
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! SheetSearchSuggestionCell
        cell.txtName.text = "  " + self.items[indexPath.row].label + "  "
        cell.txtName.textColor = service?.color.darkerColor()
        cell.txtName.font = self.items[indexPath.row].isField ? SheetsManagerSuggestionsView.boldFont : SheetsManagerSuggestionsView.regularFont
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didSelectSuggestion(items[indexPath.row].label)
    }
}