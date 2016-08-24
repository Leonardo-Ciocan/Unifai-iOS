import UIKit
import AlamofireImage
import Alamofire
import PKHUD

protocol SheetCellDelegate {
    func shouldOpenLinkWithURL(url:String)
    func shouldSendMessageWithText(text:String, sourceRect:CGRect, sourceView:UIView)
}

class SheetCell: UICollectionViewCell {

    var UICache : [[UIView]] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = false
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSizeZero
        layer.shadowRadius = 10
    }
    var entries : [SheetEntry] = []
    var delegate : SheetCellDelegate?
    
    var cellWasInitialized = false
    
    static let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .FIFO,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )
    
    func loadEntries(entries:[SheetEntry]) {
        self.entries = entries
        for (index,entry) in entries.enumerate() {
            let height = CGFloat(entry.size())
            let y = CGFloat((Array<SheetEntry>(entries[0..<index])).reduce(0, combine: {$0 + $1.size()}))
            switch entry {
            case let entry as TitledSheetEntry:
                let item = cellWasInitialized ?
                    UICache[index][0] as! TitledSheetItemView :
                    TitledSheetItemView(frame: CGRect(x: CGFloat(0), y: y, width: frame.width, height: height))
                item.txtName.text = entry.title
                item.txtSubtitle.text = entry.subtitle
                
                if !cellWasInitialized {
                    addSubview(item)
                    UICache.append([item])
                }
            case let entry as TextSheetEntry:
                let item = cellWasInitialized ?
                    UICache[index][0] :
                    UIView(frame: CGRect(x: CGFloat(0), y: y, width: frame.width, height: height))
                let label = cellWasInitialized ?
                    UICache[index][1] as! UILabel :
                    UILabel()
                label.text = entry.text
                
                if !cellWasInitialized {
                    item.backgroundColor = currentTheme.shadeColor
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
                    UICache.append([item,label])
                }
            case let entry as ActionSheetEntry:
                let item = cellWasInitialized ?
                    UICache[index][0] as! UIButton :
                    UIButton(frame: CGRect(x: CGFloat(15), y: y+10, width: frame.width - 30, height: height - 20))
                
                item.setTitle(entry.label, forState: .Normal)
               
                if !cellWasInitialized {
                    item.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.04)
                    item.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    item.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).CGColor
                    item.layer.borderWidth = 1
                    item.titleLabel!.font = item.titleLabel!.font.fontWithSize(12)
                    item.tag = index
                    item.addTarget(self, action: #selector(tappedButton), forControlEvents: .TouchUpInside)
                    addSubview(item)
                    UICache.append([item])
                }
            case let entry as ImageSheetEntry:
                let imageview = cellWasInitialized ?
                    UICache[index][0] as! UIImageView :
                    UIImageView(frame: CGRect(x: 0, y: y , width: 200, height: 200))
                let blurView = cellWasInitialized ?
                    UICache[index][1] as! UIVisualEffectView :
                    UIVisualEffectView(frame: CGRect(x: 0, y: y + 160 , width: 200, height: 40))
                
                let label = cellWasInitialized ?
                    UICache[index][2] as! UILabel :
                    UILabel()
                
                let indicator = cellWasInitialized ?
                    UICache[index][3] as! UIActivityIndicatorView :
                    UIActivityIndicatorView(frame:imageview.frame)
                
                label.text = entry.title
                indicator.startAnimating()
                imageview.image = nil
                if entry.url == "" {
                    indicator.stopAnimating()
                }
                else {
                    let URLRequest = NSURLRequest(URL: NSURL(string:entry.url)!)
                    
                    SheetCell.imageDownloader.downloadImage(URLRequest: URLRequest) { response in
                        if let image = response.result.value {
                            imageview.image = image.af_imageAspectScaledToFillSize(CGSize(width: 200, height: 200))
                            indicator.stopAnimating()
                        }
                    }

                }
                
                
                if !cellWasInitialized {
                    blurView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
                    blurView.effect = UIBlurEffect(style: .Light)
                    label.layer.shadowOffset = CGSizeZero
                    label.layer.shadowColor = UIColor.blackColor().CGColor
                    label.layer.shadowOpacity = 0.25
                    label.layer.shadowRadius = 5
                    label.textColor = UIColor.whiteColor()
                    label.font = label.font.fontWithSize(13)
                    label.textAlignment = .Center
                    
                    addSubview(imageview)
                    addSubview(blurView)
                    addSubview(indicator)
                    blurView.addSubview(label)
                    label.snp_makeConstraints(closure: { make in
                        make.center.equalTo(blurView)
                        make.width.equalTo(blurView).offset(-20)
                        make.height.equalTo(blurView)
                    })
                    UICache.append([imageview,blurView,label,indicator])
                }
            default:
                continue
            }
           
        }
        cellWasInitialized = true

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
        else if actionEntry.action == "copy" {
            UIPasteboard.generalPasteboard().string = actionEntry.value
            PKHUD.sharedHUD.dimsBackground = false
            HUD.flash(.Success, delay: 0.75)
        }
    }
}
