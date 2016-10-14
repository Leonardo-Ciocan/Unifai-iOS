import UIKit
import DateTools
import ActiveLabel
import GSImageViewerController
import SafariServices
import Charts
import Alamofire
import AlamofireImage
import PKHUD

protocol MessageCellDelegate {
    func shouldSendMessageWithText(_ text:String, sourceRect:CGRect, sourceView:UIView)
    func didFinishAuthenticationFromMessage(_ message:Message?)
}

extension UITextView {
    func setHTMLFromString(_ text: String, color:UIColor) {
        let textColor = self.textColor ?? UIColor.black
        let font = Constants.standardFont
        let imgSizeStyle = "<head>" +
        "   <style>" +
        "        img,div {max-width: \(self.frame.width * 0.95)px; height: auto;}" +
        "   "
        let modifiedFont = imgSizeStyle + " body {font-family: '\(font!.fontName)'; font-size: \(font!.pointSize) }</style></head> " + text
        
        
        
        let attrStr = try! NSMutableAttributedString(
            data: modifiedFont.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8],
            documentAttributes: nil)
        
//        let flatText = attrStr.string
//        let types: NSTextCheckingType = .Link
//        
//        let detector = try? NSDataDetector(types: types.rawValue)
//        
//        guard let detect = detector else {
//            return
//        }
//        
//        let matches = detect.matchesInString(flatText, options: .ReportCompletion, range: NSMakeRange(0, flatText.characters.count))
//        
//        for match in matches {
////            attrStr.addAttribute(NSLinkAttributeName, value: (match.URL?.absoluteURL)! , range: match.range)
//            attrStr.addAttribute(NSForegroundColorAttributeName, value: color , range: match.range)
//        }
        self.text = nil
        self.attributedText = nil
        self.attributedText = attrStr
        self.sizeToFit()
    }
}


class MessageCell: UITableViewCell, SheetsViewDelegate, AuthViewDelegate, UITextViewDelegate{
    
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtUsername: UILabel!
    @IBOutlet weak var txtBody: UITextView!
    @IBOutlet weak var imgLogo: UIButton!
    @IBOutlet weak var txtTime: UILabel!
    
    @IBOutlet weak var payloadContainer: UIView!
    @IBOutlet weak var payloadContainerHeight: NSLayoutConstraint!

    @IBOutlet weak var threadCount: UILabel!
    @IBOutlet weak var threadCountView: UIView!
    var parentViewController : UIViewController?
    
    var img : UIImage?
    var imgView : UIImageView?
    var delegate : MessageCellDelegate?
    
    @IBOutlet weak var txtBodyLeadingConstraint: NSLayoutConstraint!
    var hideTime : Bool{
        set(hide){
            txtTime.isHidden = hide
        }
        get{
            return txtTime.isHidden
        }
    }
    
    var hideServiceMarkings : Bool? {
        didSet {
            txtName.isHidden = hideServiceMarkings!
            imgLogo.isHidden = hideServiceMarkings!
            txtBodyLeadingConstraint.constant = hideServiceMarkings! ? 20 : 73
            layoutIfNeeded()
        }
    }
    
    static let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )
    
    var shouldShowText = true
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgLogo.layer.cornerRadius = imgLogo.frame.width/2
        imgLogo.layer.masksToBounds = true
//        textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
        txtBody.delegate = self
        
        contentView.isUserInteractionEnabled = false
        threadCountView.layer.masksToBounds = true
        threadCountView.layer.cornerRadius = 10
        threadCountView.layer.borderWidth = 2
        threadCountView.layer.borderColor = currentTheme.backgroundColor.cgColor
        self.backgroundColor = currentTheme.backgroundColor
        txtBody.textColor = currentTheme.foregroundColor
        txtName.textColor = currentTheme.foregroundColor
        
        payloadContainer.backgroundColor = UIColor.clear
        
        let textSize = [10,15,20][Settings.textSize]
        let font = UIFont.systemFont(ofSize: CGFloat(textSize), weight: UIFontWeightThin)
        txtBody.font = font
        
        txtTime.font = font
        
//        txtBody.handleURLTap({url in
//            let alert = UIAlertController(title: "", message: url.absoluteString, preferredStyle: .ActionSheet)
//            alert.addAction(UIAlertAction(title: "Open link", style: .Default, handler: { _ in
//                let svc = SFSafariViewController(URL: url)
//                self.parentViewController!.presentViewController(svc, animated: true, completion: nil)
//            }))
//            alert.addAction(UIAlertAction(title: "Copy link", style: .Default, handler: { _ in
//                UIPasteboard.generalPasteboard().string = url.absoluteString
//            }))
//            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
//                alert.dismissViewControllerAnimated(true, completion: nil)
//            }))
//            
//            let popover = alert.popoverPresentationController
//            if let popover = popover {
//                popover.sourceView = self.txtBody
//                popover.sourceRect = self.txtBody.bounds
//                popover.permittedArrowDirections = .Any
//            }
//            self.parentViewController!.presentViewController(alert, animated: true, completion: nil)
//        })
        
        let longTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTappedMessage))
        txtBody.addGestureRecognizer(longTapRecognizer)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let svc = SFSafariViewController(url: URL)
        self.parentViewController!.present(svc, animated: true, completion: nil)
        return false
    }
    
    func longTappedMessage() {
        guard let message = self.message else { return }
        guard message.isFromUser else { return }
        guard let serviceColor = TextUtils.extractServiceColorFrom(txtBody.text!) else { return }
        HUD.dimsBackground = false

        let actionPicker = UIAlertController(title: "What do you want to do with this message?", message: txtBody.text , preferredStyle: .actionSheet)
        actionPicker.addAction(UIAlertAction(title: "Add to the top of my dashboard", style: .default, handler: {
             _ in
            Unifai.getDashboardItems({ items in
                let newItems = [self.txtBody.text!] + items
                Unifai.setDashboardItems(newItems, completion: { _ in
                    HUD.dimsBackground = false
                    HUD.flash(.success, delay: 1)
                })
            })
        }))
        
        actionPicker.addAction(UIAlertAction(title: "Add to the bottom of my dashboard", style: .default, handler: {
            _ in
            Unifai.getDashboardItems({ items in
                let newItems = items + [self.txtBody.text!]
                Unifai.setDashboardItems(newItems, completion: { _ in
                    HUD.flash(.success, delay: 1)
                })
            })
        }))
        
        actionPicker.addAction(UIAlertAction(title: "Save as action", style: .default, handler: {
            _ in
            let namePrompt = UIAlertController(title: "How do you want to call this?", message: "", preferredStyle: .alert)
            namePrompt.addTextField(configurationHandler: { textField in
                textField.placeholder = "Enter a name for this action"
                textField.clearButtonMode = .whileEditing
            })
            
            namePrompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            namePrompt.addAction(UIAlertAction(title: "Create action", style: .default, handler: { _ in
                guard let name = namePrompt.textFields![0].text else { return }
                let action = Action(message: self.txtBody.text!, name: name)
                Core.Actions.append(action)
                Unifai.createAction(self.txtBody.text!, name: name, completion: {
                        HUD.flash(.success, delay: 1)
                    }, error: {
                        HUD.flash(.error,delay: 1)
                })
            }))
            self.parentViewController!.present(namePrompt, animated: true, completion: {
                UIView.animate(withDuration: 0.5, animations: {
                    namePrompt.view.tintColor = serviceColor
                })
            })
        }))
        
        actionPicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let popover = actionPicker.popoverPresentationController
        if let popover = popover {
            popover.sourceView = self.txtBody
            popover.sourceRect = self.txtBody.bounds
            popover.permittedArrowDirections = .any
        }
        self.parentViewController!.present(actionPicker, animated: true, completion: {
            UIView.animate(withDuration: 0.5, animations: {
                actionPicker.view.tintColor = serviceColor
            })
        })
        
    }
    
    func handleMessage() {
        guard let message = self.message else { return }
        self.txtBody.setHTMLFromString(message.body,color: message.service?.color ?? Constants.appBrandColor)
        self.txtBody.tintColor = message.service?.color
        imgLogo.backgroundColor = message.service?.color
//        backgroundShadowView.layer.borderColor = message.service?.color.CGColor
//        backgroundShadowView.layer.borderWidth = 0
//        backgroundShadowView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.02)
        
        imgLogo.setImage(message.logo, for: UIControlState())
        txtName.textColor = message.color
        
        self.txtName.text = message.isFromUser ? Core.Username.uppercased() : message.service?.name.uppercased()
//        txtBody.URLColor = message.color
//        if message.isFromUser {
//            let atColor = TextUtils.extractServiceColorFrom(message.body)
//            txtBody.mentionColor = atColor!
//        }
    }
    
    func handleThreadCount(_ shouldShowThreadCount: Bool) {
        guard let message = self.message else { return }
        if shouldShowThreadCount {
            threadCountView.backgroundColor = message.service?.color
            threadCount.text = String(message.messagesInThread)
        } else {
            threadCountView.isHidden = true
        }
    }
    
    func handleTime() {
        guard let message = self.message else { return }
        let timeSinceMessage = Date().timeIntervalSince(message.timestamp as Date)
        self.txtTime.text = timeSinceMessage < 60 ? "just now" : (message.timestamp as NSDate).shortTimeAgoSinceNow()
    }
    
    func handleTablePayload() {
        guard let message = self.message else { return }
        
        if let payload = message.payload  as? TablePayload {
            self.payloadContainerHeight.constant = CGFloat(payload.rows.count) * 50 + 50
            let tableView = TablePayloadView()
            self.payloadContainer.addSubview(tableView)
            tableView.snp_makeConstraints(closure: { (make)->Void in
                make.trailing.equalTo(0)
                make.leading.equalTo(self.hideServiceMarkings ?? false ? -45 : 0)
                make.bottom.top.equalTo(0)
            })
            tableView.loadData(message.payload as! TablePayload)
            
        }
    }
    
    func handleImagePayload() {
        guard let message = self.message else { return }

        if (message.payload as! ImagePayload).URL.isEmpty {
            self.payloadContainerHeight.constant = 0
            return
        }
        else {
            self.payloadContainerHeight.constant = 180
        }
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.15
        imageView.layer.shadowOffset = CGSize.zero
        imageView.layer.shadowRadius = 10
        
        let URLRequest = Foundation.URLRequest(url: URL(string:(message.payload as! ImagePayload).URL)!)
        MessageCell.imageDownloader.downloadImage(URLRequest: URLRequest) { response in
            if let image = response.result.value {
                self.img = image
                imageView.image = image.af_imageAspectScaledToFitSize(CGSize(width: 250, height: 150))
            }
        }

        
        
        self.imgView = imageView
        
        imageView.contentMode = .scaleAspectFit
        self.payloadContainer.addSubview(imageView)
        imageView.snp_makeConstraints(closure: { (make)->Void in
            make.trailing.leading.equalTo(0)
            make.bottom.top.equalTo(0)
        })
        
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(payloadImageTapped))
        singleTap.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
        
        let longTap = UILongPressGestureRecognizer(target: self, action:#selector(payloadImageWasLongTapped))
        imageView.addGestureRecognizer(longTap)
    }
    
    func handleBarChartPayload() {
        guard let message = self.message else { return }

        self.payloadContainerHeight.constant = 180
        
        let view = BarChartView()
        view.userInteractionEnabled = false
        let payload = message.payload as! BarChartPayload
        var yVals : [BarChartDataEntry]  = []
        for (index, item) in payload.values.enumerated(){
            yVals.append(BarChartDataEntry(value: Double(item), xIndex: index))
        }
        
        let dataSet = BarChartDataSet(yVals: yVals, label: "")
        dataSet.valueFormatter = NumberFormatter()
        dataSet.valueFormatter?.minimumFractionDigits = 0
        
        dataSet.colors = [message.color]
        let data = BarChartData(xVals: payload.labels, dataSet: dataSet)
        view.data = data
        view.tintColor = message.color
        view.rightAxis.labelTextColor = UIColor.clearColor()
        view.leftAxis.axisMinValue = 0
        view.borderColor = UIColor.clearColor()
        view.drawGridBackgroundEnabled = false
        view.legend.enabled = false
        view.gridBackgroundColor = UIColor.clearColor()
        view.xAxis.drawGridLinesEnabled = false
        view.leftAxis.drawGridLinesEnabled = false
        view.rightAxis.drawGridLinesEnabled = false
        view.drawBordersEnabled = false
        view.xAxis.drawAxisLineEnabled = false
        view.descriptionText = ""
        view.leftAxis.drawAxisLineEnabled = false
        view.rightAxis.drawAxisLineEnabled = false
        view.xAxis.labelPosition = .Bottom
        view.backgroundColor = UIColor.clearColor()
        view.leftAxis.valueFormatter = NumberFormatter()
        view.leftAxis.valueFormatter?.minimumFractionDigits = 0
        view.leftAxis.labelTextColor = currentTheme.foregroundColor
        view.xAxis.labelTextColor = currentTheme.foregroundColor
        view.leftAxis.labelTextColor = currentTheme.foregroundColor
        
        self.payloadContainer.addSubview(view)
        
        view.snp_makeConstraints(closure: { (make)->Void in
            make.trailing.leading.equalTo(0)
            make.bottom.top.equalTo(0)
        })
    }
    
    func handleAuthPayload() {
        guard let message = self.message else { return }
        self.payloadContainerHeight.constant = 35
        let btn = LoginButton()
        btn.setService(message.service!)
        self.payloadContainer.addSubview(btn)
        
        
        let recon = UITapGestureRecognizer(target: self, action: #selector(loginButtonWasTapped))
        btn.addGestureRecognizer(recon)
        
        
        btn.snp_makeConstraints(closure: { (make)->Void in
            make.trailing.equalTo(0)
            make.leading.equalTo((self.hideServiceMarkings ?? false ? -50 : 0))
            make.height.equalTo(35)
            make.top.equalTo(0)
        })
    }
    
    func handleCardListPayload() {
        guard let message = self.message else { return }
        
        
        let cardSize = [100,150,200][Settings.cardSize]
        self.payloadContainerHeight.constant = CGFloat(cardSize + 20)
        
        let scrollView = UIScrollView()
        scrollView.canCancelContentTouches=false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 10)
        let payload = message.payload as! CardListPayload
        scrollView.contentSize = CGSize(width: cardSize * payload.items.count + (payload.items.count-1) * 10 + 77, height: cardSize)
        
        var lastCard : CardView? = nil
        for (index,item) in payload.items.enumerated(){
            let card = CardView()
            
            let recon = UITapGestureRecognizer(target: self, action: #selector(onCardTapped))
            card.addGestureRecognizer(recon)
            
            card.loadData(item,service:message.service!)
            scrollView.addSubview(card)
            card.snp_makeConstraints(closure: { (make)->Void in
                make.height.equalTo(cardSize)
                make.top.equalTo(0)
                make.width.equalTo(cardSize)
                if index == 0 {
                    make.leading.equalTo(self.hideServiceMarkings != true ? 77 : 20)
                }
                else{
                    make.left.equalTo((lastCard?.snp_right)!).offset(10)
                    
                }
            })
            lastCard = card
        }
        self.payloadContainer.addSubview(scrollView)
        scrollView.snp_makeConstraints(closure: { (make)->Void in
            make.leading.equalTo(-67)
            make.trailing.equalTo(19)
            make.top.bottom.equalTo(0)
        })

    }
    
    func handleProgressPayload() {
        guard let message = self.message else { return }
        
        let progressView = ProgressView()
        self.payloadContainerHeight.constant = 90
        self.payloadContainer.addSubview(progressView)
        
        let payload = message.payload as! ProgressPayload
        
        progressView.snp_makeConstraints(closure: { make in
            make.trailing.top.bottom.equalTo(0)
            make.leading.equalTo(self.hideServiceMarkings != true ? 0 : -47)
        })
        
        progressView.setProgressValues(payload.min, max: payload.max, value: payload.value)
        progressView.progressBar.backgroundColor = message.service?.color
        progressView.valueBackground.backgroundColor = message.service?.color
        progressView.barView.layer.borderColor = message.service?.color.cgColor
        progressView.barView.layer.borderWidth = 1
    }
    
    func handleImageUploadPayload() {
        guard let message = self.message else { return }
        
        self.payloadContainerHeight.constant = 180
        
        let imageView = UIImageView()
        self.imgView = imageView
        
        Unifai.getDataForMessage(withID: message.id, completion: { data in
            imageView.image = UIImage(data: data as Data)
        })
        
        imageView.contentMode = .scaleAspectFit
        self.payloadContainer.addSubview(imageView)
        imageView.snp_makeConstraints(closure: { (make)->Void in
            make.trailing.leading.equalTo(0)
            make.bottom.top.equalTo(0)
        })
    }
    
    func handleSheetsPayload() {
        guard let message = self.message else { return }
        
        let payload = message.payload as! SheetsPayload
        if payload.sheets.count == 0 {
            return
        }
        let height = payload.sheets[0].entries.reduce(0){$0 + $1.size()}
        self.payloadContainerHeight.constant = CGFloat(height) + 40
        
        let sheetsView = SheetsView()
        sheetsView.backgroundColor = UIColor.clear
        sheetsView.delegate = self
        sheetsView.loadSheets(payload.sheets, color: message.color, service:message.service)
        sheetsView.collectionView.contentInset = UIEdgeInsets(top: 10, left: self.hideServiceMarkings != true ? 77 : 20, bottom: 0, right: 10)
        self.payloadContainer.addSubview(sheetsView)
        sheetsView.snp_makeConstraints(closure: { (make)->Void in
            make.leading.equalTo(-67)
            make.trailing.equalTo(19)
            make.top.bottom.equalTo(0)
        })
    }
    
    func shouldOpenSheetsManagerWithSheets(_ sheets: [Sheet], service: Service) {
        let rootVC = SheetsManagerViewController()
        //let nav = UINavigationController(rootViewController: rootVC)
        let height = CGFloat(sheets[0].entries.reduce(0){$0 + $1.size()})
        rootVC.loadSheets(sheets, service: service, itemHeight: height)
        self.parentViewController?.present(rootVC, animated: true, completion: nil)
    }
    
    func handlePayload() {
        guard let message = self.message else { return }
        self.payloadContainer.subviews.forEach { $0.removeFromSuperview() }
        
        if !self.shouldShowText {
            self.payloadContainerHeight.constant = 0
            return
        }
        
        switch message.type {
        case .text , .prompt:
            self.payloadContainerHeight.constant = 0
        case .table:
            handleTablePayload()
        case .image:
            handleImagePayload()
        case .barChart:
            handleBarChartPayload()
        case .requestAuth:
            handleAuthPayload()
        case .cardList:
            handleCardListPayload()
        case .progress:
            handleProgressPayload()
        case .imageUpload:
            handleImageUploadPayload()
        case .sheets:
            handleSheetsPayload()
        default:
            break
        }

    }
    
    var message : Message?
    func setMessage(_ message : Message , shouldShowThreadCount : Bool = false){
        self.message = message
        handleMessage()
        handleThreadCount(shouldShowThreadCount)
        handleTime()
        handlePayload()
    }
    
    func shouldSendMessageWithText(_ text: String, sourceRect: CGRect, sourceView: UIView) {
        delegate?.shouldSendMessageWithText(text, sourceRect: sourceRect, sourceView: sourceView)
    }
    
    func shouldOpenLinkWithURL(_ url: String) {
        let svc = SFSafariViewController(url: URL(string: url)!)
        self.parentViewController!.present(svc, animated: true, completion: nil)
    }
    
    func payloadImageTapped(_ senderA:UITapGestureRecognizer){
        guard let message = self.message else { return }
        let URLRequest = Foundation.URLRequest(url: URL(string:(message.payload as! ImagePayload).URL)!)
        MessageCell.imageDownloader.downloadImage(URLRequest: URLRequest) { response in
            if let image = response.result.value {
                let imageInfo      = GSImageInfo(image: image, imageMode: .AspectFit, imageHD: nil)
                let transitionInfo = GSTransitionInfo(fromView: senderA.view!)
                let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                self.parentViewController!.presentViewController(imageViewer, animated: true, completion: nil)
            }
        }
    }
    
    func payloadImageWasLongTapped(_ senderA:UITapGestureRecognizer){
        guard let message = self.message else { return }
        let URLRequest = Foundation.URLRequest(url: URL(string:(message.payload as! ImagePayload).URL)!)
        MessageCell.imageDownloader.downloadImage(URLRequest: URLRequest) { response in
            if let image = response.result.value {
                let prompt = UIAlertController(title: "Do you want to save this image?", message: "", preferredStyle: .actionSheet)
                prompt.addAction(UIAlertAction(title: "Save image", style: .default, handler: { _ in
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    HUD.flash(.success, delay: 0.35)
                }))
                prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.parentViewController?.present(prompt, animated: true, completion: nil)
            }
        }
    }
    
    func onCardTapped(_ recon:UITapGestureRecognizer){
        let view = recon.view as! CardView
        let svc = SFSafariViewController(url: URL(string: view.navigateURL)!)
        self.parentViewController!.present(svc, animated: true, completion: nil)
    }
    
    func loginButtonWasTapped(_ recon:UITapGestureRecognizer){
        let payload = message?.payload as! RequestAuthPayload
        
        let vc = AuthViewController()
        vc.delegate = self
        vc.payload = payload
        vc.service = message?.service
        self.parentViewController?.present(vc, animated: true, completion: nil)
    }

    func didFinishAuthentication() {
        self.delegate?.didFinishAuthenticationFromMessage(self.message)
    }

    @IBAction func profilePictureTapped(_ sender: AnyObject) {
        guard self.message?.service != nil else { return }
        let profileVC = UIStoryboard(name: "Feed", bundle: nil).instantiateViewController(withIdentifier: "profile") as! ServiceProfileViewcontroller
        profileVC.loadData(self.message!.service)
        let nav = UINavigationController(rootViewController: profileVC)
        
        nav.modalPresentationStyle = .popover
        let viewForSource = sender as! UIView
        nav.popoverPresentationController!.sourceView = viewForSource
        
        // the position of the popover where it's showed
        nav.popoverPresentationController!.sourceRect = viewForSource.bounds
        
        // the size you want to display
        nav.preferredContentSize = CGSize(width: 300,height: 450)
        
        self.parentViewController!.present(nav, animated: true, completion: nil)
    }
    
}
