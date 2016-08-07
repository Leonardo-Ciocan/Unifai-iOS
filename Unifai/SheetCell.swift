import UIKit

protocol SheetCellDelegate {
    func shouldOpenLinkWithURL(url:String)
    func shouldSendMessageWithText(text:String, sourceRect:CGRect, sourceView:UIView)
}

class SheetCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        //backgroundColor = currentTheme.shadeColor
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    var entries : [SheetEntry] = []
    var delegate : SheetCellDelegate?
    
    func loadEntries(entries:[SheetEntry]) {
        self.entries = entries
        subviews.forEach({$0.removeFromSuperview()})
        for (index,entry) in entries.enumerate() {
            let height = CGFloat(entry.size())
            let y = CGFloat((Array<SheetEntry>(entries[0..<index])).reduce(0, combine: {$0 + $1.size()}))
            switch entry {
            case let entry as TitledSheetEntry:
                let item = TitledSheetItemView(frame: CGRect(x: CGFloat(0), y: y, width: frame.width, height: height))
                item.txtName.text = entry.title
                item.txtSubtitle.text = entry.subtitle
                addSubview(item)
            case let entry as TextSheetEntry:
                let item = UIView(frame: CGRect(x: CGFloat(0), y: y, width: frame.width, height: height))
                item.backgroundColor = currentTheme.shadeColor
                let label = UILabel()
                label.text = entry.text
                label.textColor = UIColor.whiteColor()
                label.font = label.font.fontWithSize(13)
                label.adjustsFontSizeToFitWidth = true
                label.textAlignment = .Center
                item.addSubview(label)
                label.snp_makeConstraints(closure: { make in
                    make.center.equalTo(item)
                    make.width.equalTo(item).offset(-20)
                    make.height.equalTo(item)
                })
                addSubview(item)
            case let entry as ActionSheetEntry:
                let item = UIButton(frame: CGRect(x: CGFloat(15), y: y+5, width: frame.width - 30, height: height - 10))
                item.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.03)
                item.setTitle(entry.label, forState: .Normal)
                item.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                item.layer.cornerRadius = 5
                item.layer.masksToBounds = true
                item.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).CGColor
                item.layer.borderWidth = 1
                item.titleLabel!.font = item.titleLabel!.font.fontWithSize(12)
                item.tag = index
                item.addTarget(self, action: #selector(tappedButton), forControlEvents: .TouchUpInside)
                addSubview(item)
            default:
                continue
            }
           
            
        }
    }
    
    func tappedButton(sender:UIButton) {
        let index = sender.tag 
        let actionEntry = (entries[index] as! ActionSheetEntry)
        if actionEntry.action == "url" {
            delegate?.shouldOpenLinkWithURL(actionEntry.value)
        }
        else if actionEntry.action == "send" {
            delegate?.shouldSendMessageWithText(actionEntry.value,sourceRect:  sender.bounds ,sourceView:  sender)
        }
    }
}
