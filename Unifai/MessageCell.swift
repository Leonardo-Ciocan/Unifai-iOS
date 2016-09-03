//
//  MessageCell.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 26/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

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
    func shouldSendMessageWithText(text:String, sourceRect:CGRect, sourceView:UIView)
    func didFinishAuthentication()
}

class MessageCell: UITableViewCell, SheetsViewDelegate, AuthViewDelegate {
    
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtUsername: UILabel!
    @IBOutlet weak var txtBody: ActiveLabel!
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
            txtTime.hidden = hide
        }
        get{
            return txtTime.hidden
        }
    }
    
    var hideServiceMarkings : Bool? {
        didSet {
            txtName.hidden = hideServiceMarkings!
            imgLogo.hidden = hideServiceMarkings!
            txtBodyLeadingConstraint.constant = hideServiceMarkings! ? 20 : 73
            layoutIfNeeded()
        }
    }
    
    var shouldShowText = true
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgLogo.layer.cornerRadius = imgLogo.frame.width/2
        imgLogo.layer.masksToBounds = true
        
        
        
        contentView.userInteractionEnabled = false
        threadCountView.layer.masksToBounds = true
        threadCountView.layer.cornerRadius = 10
        threadCountView.layer.borderWidth = 2
        threadCountView.layer.borderColor = currentTheme.backgroundColor.CGColor
        self.backgroundColor = currentTheme.backgroundColor
        txtBody.textColor = currentTheme.foregroundColor
        txtName.textColor = currentTheme.foregroundColor
        
        payloadContainer.backgroundColor = UIColor.clearColor()
        
        let textSize = [10,15,20][Settings.textSize]
        let font = UIFont.systemFontOfSize(CGFloat(textSize), weight: UIFontWeightThin)
        txtBody.font = font
        txtTime.font = font
        
        txtBody.handleURLTap({url in
            let alert = UIAlertController(title: "", message: url.absoluteString, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Open link", style: .Default, handler: { _ in
                let svc = SFSafariViewController(URL: url)
                self.parentViewController!.presentViewController(svc, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Copy link", style: .Default, handler: { _ in
                UIPasteboard.generalPasteboard().string = url.absoluteString
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            let popover = alert.popoverPresentationController
            if let popover = popover {
                popover.sourceView = self.txtBody
                popover.sourceRect = self.txtBody.bounds
                popover.permittedArrowDirections = .Any
            }
            self.parentViewController!.presentViewController(alert, animated: true, completion: nil)
        })
        
        let longTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTappedMessage))
        txtBody.addGestureRecognizer(longTapRecognizer)
    }
    
    func longTappedMessage() {
        guard let message = self.message else { return }
        guard message.isFromUser else { return }
        guard let serviceColor = TextUtils.extractServiceColorFrom(txtBody.text!) else { return }
        HUD.dimsBackground = false

        let actionPicker = UIAlertController(title: "What do you want to do with this message?", message: txtBody.text , preferredStyle: .ActionSheet)
        actionPicker.addAction(UIAlertAction(title: "Add to the top of my dashboard", style: .Default, handler: {
             _ in
            Unifai.getDashboardItems({ items in
                let newItems = [self.txtBody.text!] + items
                Unifai.setDashboardItems(newItems, completion: { _ in
                    HUD.dimsBackground = false
                    HUD.flash(.Success, delay: 1)
                })
            })
        }))
        
        actionPicker.addAction(UIAlertAction(title: "Add to the bottom of my dashboard", style: .Default, handler: {
            _ in
            Unifai.getDashboardItems({ items in
                let newItems = items + [self.txtBody.text!]
                Unifai.setDashboardItems(newItems, completion: { _ in
                    HUD.flash(.Success, delay: 1)
                })
            })
        }))
        
        actionPicker.addAction(UIAlertAction(title: "Save as action", style: .Default, handler: {
            _ in
            let namePrompt = UIAlertController(title: "How do you want to call this?", message: "", preferredStyle: .Alert)
            namePrompt.addTextFieldWithConfigurationHandler({ textField in
                textField.placeholder = "Enter a name for this action"
                textField.clearButtonMode = .WhileEditing
            })
            
            namePrompt.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            namePrompt.addAction(UIAlertAction(title: "Create action", style: .Default, handler: { _ in
                guard let name = namePrompt.textFields![0].text else { return }
                let action = Action(message: self.txtBody.text!, name: name)
                Core.Actions.append(action)
                Unifai.createAction(self.txtBody.text!, name: name, completion: {
                        HUD.flash(.Success, delay: 1)
                    }, error: {
                        HUD.flash(.Error,delay: 1)
                })
            }))
            self.parentViewController!.presentViewController(namePrompt, animated: true, completion: {
                UIView.animateWithDuration(0.5, animations: {
                    namePrompt.view.tintColor = serviceColor
                })
            })
        }))
        
        actionPicker.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        let popover = actionPicker.popoverPresentationController
        if let popover = popover {
            popover.sourceView = self.txtBody
            popover.sourceRect = self.txtBody.bounds
            popover.permittedArrowDirections = .Any
        }
        self.parentViewController!.presentViewController(actionPicker, animated: true, completion: {
            UIView.animateWithDuration(0.5, animations: {
                actionPicker.view.tintColor = serviceColor
            })
        })
        
    }
    
    func handleMessage() {
        guard let message = self.message else { return }
        self.txtBody.text = message.body
        imgLogo.backgroundColor = message.service?.color
//        backgroundShadowView.layer.borderColor = message.service?.color.CGColor
//        backgroundShadowView.layer.borderWidth = 0
//        backgroundShadowView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.02)
        
        imgLogo.setImage(message.logo, forState: .Normal)
        txtName.textColor = message.color
        
        self.txtName.text = message.isFromUser ? Core.Username.uppercaseString : message.service?.name.uppercaseString
        txtBody.URLColor = message.color
        if message.isFromUser {
            let atColor = TextUtils.extractServiceColorFrom(message.body)
            txtBody.mentionColor = atColor!
        }
    }
    
    func handleThreadCount(shouldShowThreadCount: Bool) {
        guard let message = self.message else { return }
        if shouldShowThreadCount {
            threadCountView.backgroundColor = message.service?.color
            threadCount.text = String(message.messagesInThread)
        } else {
            threadCountView.hidden = true
        }
    }
    
    func handleTime() {
        guard let message = self.message else { return }
        let timeSinceMessage = NSDate().timeIntervalSinceDate(message.timestamp)
        self.txtTime.text = timeSinceMessage < 60 ? "just now" : message.timestamp.shortTimeAgoSinceNow()
    }
    
    func handleTablePayload() {
        guard let message = self.message else { return }
        
        if let payload = message.payload  as? TablePayload {
            self.payloadContainerHeight.constant = CGFloat(payload.rows.count) * 50 + 50
            let tableView = TablePayloadView()
            self.payloadContainer.addSubview(tableView)
            tableView.snp_makeConstraints(closure: { (make)->Void in
                make.trailing.leading.equalTo(0)
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
        self.payloadContainerHeight.constant = 180
        
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.layer.shadowColor = UIColor.blackColor().CGColor
        imageView.layer.shadowOpacity = 0.15
        imageView.layer.shadowOffset = CGSizeZero
        imageView.layer.shadowRadius = 10
        Alamofire.request(.GET, (message.payload as! ImagePayload).URL)
            .responseImage { response in
                if let image = response.result.value {
                    self.img = image
                    imageView.image = image.af_imageAspectScaledToFitSize(CGSize(width: 250, height: 150))
                }
        }
        
        
        self.imgView = imageView
        
        imageView.contentMode = .ScaleAspectFit
        self.payloadContainer.addSubview(imageView)
        imageView.snp_makeConstraints(closure: { (make)->Void in
            make.trailing.leading.equalTo(0)
            make.bottom.top.equalTo(0)
        })
        
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(payloadImageTapped))
        singleTap.numberOfTapsRequired = 1
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
    }
    
    func handleBarChartPayload() {
        guard let message = self.message else { return }

        self.payloadContainerHeight.constant = 180
        
        let view = BarChartView()
        view.userInteractionEnabled = false
        let payload = message.payload as! BarChartPayload
        var yVals : [BarChartDataEntry]  = []
        for (index, item) in payload.values.enumerate(){
            yVals.append(BarChartDataEntry(value: Double(item), xIndex: index))
        }
        
        let dataSet = BarChartDataSet(yVals: yVals, label: "")
        dataSet.valueFormatter = NSNumberFormatter()
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
        view.leftAxis.valueFormatter = NSNumberFormatter()
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
        
        
        let recon = UITapGestureRecognizer(target: self, action: #selector(onTap))
        btn.addGestureRecognizer(recon)
        
        
        btn.snp_makeConstraints(closure: { (make)->Void in
            make.trailing.leading.equalTo(0)
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
        for (index,item) in payload.items.enumerate(){
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
        progressView.barView.layer.borderColor = message.service?.color.CGColor
        progressView.barView.layer.borderWidth = 1
    }
    
    func handleImageUploadPayload() {
        guard let message = self.message else { return }
        
        self.payloadContainerHeight.constant = 180
        
        let imageView = UIImageView()
        self.imgView = imageView
        
        Unifai.getDataForMessage(withID: message.id, completion: { data in
            imageView.image = UIImage(data: data)
        })
        
        imageView.contentMode = .ScaleAspectFit
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
        sheetsView.backgroundColor = UIColor.clearColor()
        sheetsView.delegate = self
        sheetsView.loadSheets(payload.sheets, color: message.color)
        sheetsView.collectionView.contentInset = UIEdgeInsets(top: 10, left: self.hideServiceMarkings != true ? 77 : 20, bottom: 0, right: 10)
        self.payloadContainer.addSubview(sheetsView)
        sheetsView.snp_makeConstraints(closure: { (make)->Void in
            make.leading.equalTo(-67)
            make.trailing.equalTo(19)
            make.top.bottom.equalTo(0)
        })
    }
    
    func handlePayload() {
        guard let message = self.message else { return }
        self.payloadContainer.subviews.forEach { $0.removeFromSuperview() }
        
        if !self.shouldShowText {
            self.payloadContainerHeight.constant = 0
            return
        }
        
        switch message.type {
        case .Text , .Prompt:
            self.payloadContainerHeight.constant = 0
        case .Table:
            handleTablePayload()
        case .Image:
            handleImagePayload()
        case .BarChart:
            handleBarChartPayload()
        case .RequestAuth:
            handleAuthPayload()
        case .CardList:
            handleCardListPayload()
        case .Progress:
            handleProgressPayload()
        case .ImageUpload:
            handleImageUploadPayload()
        case .Sheets:
            handleSheetsPayload()
        default:
            break
        }

    }
    
    var message : Message?
    func setMessage(message : Message , shouldShowThreadCount : Bool = false){
        self.message = message
        handleMessage()
        handleThreadCount(shouldShowThreadCount)
        handleTime()
        handlePayload()
    }
    
    func shouldSendMessageWithText(text: String, sourceRect: CGRect, sourceView: UIView) {
        delegate?.shouldSendMessageWithText(text, sourceRect: sourceRect, sourceView: sourceView)
    }
    
    func shouldOpenLinkWithURL(url: String) {
        let svc = SFSafariViewController(URL: NSURL(string: url)!)
        self.parentViewController!.presentViewController(svc, animated: true, completion: nil)
    }
    
    func payloadImageTapped(senderA:UITapGestureRecognizer){
        let sender = senderA.view as! UIImageView
        let imageInfo      = GSImageInfo(image: sender.image!, imageMode: .AspectFit, imageHD: nil)
        let transitionInfo = GSTransitionInfo(fromView: sender)
        let imageViewer    = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        self.parentViewController!.presentViewController(imageViewer, animated: true, completion: nil)
    }
    
    func onCardTapped(recon:UITapGestureRecognizer){
        let view = recon.view as! CardView
        let svc = SFSafariViewController(URL: NSURL(string: view.navigateURL)!)
        self.parentViewController!.presentViewController(svc, animated: true, completion: nil)
    }
    
    func onTap(recon:UITapGestureRecognizer){
        let payload = message?.payload as! RequestAuthPayload
        
        let vc = AuthViewController()
        vc.delegate = self
        vc.payload = payload
        vc.service = message?.service
        self.parentViewController?.presentViewController(vc, animated: true, completion: nil)
    }

    func didFinishAuthentication() {
        self.delegate?.didFinishAuthentication()
    }

    @IBAction func profilePictureTapped(sender: AnyObject) {
        guard self.message?.service != nil else { return }
        let profileVC = UIStoryboard(name: "Feed", bundle: nil).instantiateViewControllerWithIdentifier("profile") as! ServiceProfileViewcontroller
        profileVC.loadData(self.message!.service)
        let nav = UINavigationController(rootViewController: profileVC)
        
        nav.modalPresentationStyle = .Popover
        let viewForSource = sender as! UIView
        nav.popoverPresentationController!.sourceView = viewForSource
        
        // the position of the popover where it's showed
        nav.popoverPresentationController!.sourceRect = viewForSource.bounds
        
        // the size you want to display
        nav.preferredContentSize = CGSizeMake(300,450)
        
        self.parentViewController!.presentViewController(nav, animated: true, completion: nil)
    }
    
}
