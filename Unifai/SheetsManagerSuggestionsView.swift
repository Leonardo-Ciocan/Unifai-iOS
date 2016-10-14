import Foundation
import UIKit

struct SheetSearchSuggestionItem {
    let label : String
    let isField : Bool
    
    static func computeSuggestionsForText(_ fields:[String], text:String) -> [SheetSearchSuggestionItem] {
        let lastComponent = text.components(separatedBy: ",").last!
        if lastComponent.isEmpty {
            var initial : [SheetSearchSuggestionItem] =  ["more than","less than"].map {
                SheetSearchSuggestionItem(label: $0, isField: false)
            }
            initial.append(contentsOf: fields.map { SheetSearchSuggestionItem(label: $0, isField: true)})
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
    func didSelectSuggestion(_ text:String)
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
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        super.init(coder: aDecoder)
        collectionView!.register(UINib(nibName: "SheetSearchSuggestionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        layout.estimatedItemSize = CGSize(width: 100, height: 40)
        layout.scrollDirection = .horizontal
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
        collectionView!.backgroundColor = UIColor.clear
    }
    
    func setSuggestions(_ suggestions:[SheetSearchSuggestionItem], forService service:Service) {
        self.items = suggestions
        self.service = service
        self.collectionView!.reloadData()
    }
    
    static let regularFont = UIFont.systemFont(ofSize: 15)
    static let boldFont = UIFont.boldSystemFont(ofSize: 15)
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SheetSearchSuggestionCell
        cell.txtName.text = "  " + self.items[(indexPath as NSIndexPath).row].label + "  "
        cell.txtName.textColor = service?.color.darkerColor()
        cell.txtName.font = self.items[(indexPath as NSIndexPath).row].isField ? SheetsManagerSuggestionsView.boldFont : SheetsManagerSuggestionsView.regularFont
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.didSelectSuggestion(items[(indexPath as NSIndexPath).row].label)
    }
}
