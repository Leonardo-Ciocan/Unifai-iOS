import UIKit
import AlamofireImage
import Alamofire

protocol SheetCellDelegate {
    func shouldOpenLinkWithURL(url:String)
    func shouldSendMessageWithText(text:String, sourceRect:CGRect, sourceView:UIView)
}

class SheetCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        //backgroundColor = currentTheme.shadeColor
        layer.masksToBounds = false
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSizeZero
        layer.shadowRadius = 10
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
                label.textAlignment = .Center
                item.addSubview(label)
                label.snp_makeConstraints(closure: { make in
                    make.center.equalTo(item)
                    make.width.equalTo(item).offset(-20)
                    make.height.equalTo(item)
                })
                addSubview(item)
            case let entry as ActionSheetEntry:
                let item = UIButton(frame: CGRect(x: CGFloat(15), y: y+10, width: frame.width - 30, height: height - 10))
                item.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.04)
                item.setTitle(entry.label, forState: .Normal)
                item.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                item.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).CGColor
                item.layer.borderWidth = 1
                item.titleLabel!.font = item.titleLabel!.font.fontWithSize(12)
                item.tag = index
                item.addTarget(self, action: #selector(tappedButton), forControlEvents: .TouchUpInside)
                addSubview(item)
            case let entry as ImageSheetEntry:
                let imageview = UIImageView(frame: CGRect(x: CGFloat(200 / 2 - 25), y: y + 5, width: 60, height: 60))
                imageview.layer.cornerRadius = 5
                imageview.layer.masksToBounds = true
                imageview.layer.shadowColor = UIColor.blackColor().CGColor
                imageview.layer.shadowOffset = CGSizeZero
                imageview.layer.shadowRadius = 5
                imageview.layer.shadowOpacity = 0.1
                Alamofire.request(.GET, entry.url)
                    .responseImage { response in
                        if let image = response.result.value {
                                imageview.image = image.af_imageAspectScaledToFillSize(CGSize(width: 50, height: 50))
                        }
                }
                addSubview(imageview)
                
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
