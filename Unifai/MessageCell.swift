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
import OAuthSwift
import Alamofire
import AlamofireImage

protocol MessageCellDelegate {
    func shouldSendMessageWithText(text:String, sourceRect:CGRect, sourceView:UIView)
}

class MessageCell: UITableViewCell, SheetsViewDelegate {
    
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
    
    var hideTime : Bool{
        set(hide){
            txtTime.hidden = hide
        }
        get{
            return txtTime.hidden
        }
    }
    
    var shouldShowText = true
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgLogo.layer.cornerRadius = imgLogo.frame.width/2
        imgLogo.layer.masksToBounds = true
        
        
//        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
//        tapGestureRecognizer.numberOfTouchesRequired = 1
//        imgLogo.addGestureRecognizer(tapGestureRecognizer)
//        imgLogo.userInteractionEnabled = true
        contentView.userInteractionEnabled = false
        threadCountView.layer.masksToBounds = true
        threadCountView.layer.cornerRadius = 10
        threadCountView.layer.borderWidth = 2
        threadCountView.layer.borderColor = currentTheme.backgroundColor.CGColor
        self.backgroundColor = currentTheme.backgroundColor
        txtBody.textColor = currentTheme.foregroundColor
        txtName.textColor = currentTheme.foregroundColor
        
        payloadContainer.backgroundColor = UIColor.clearColor()
        
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
    }
    
    
    
    var message : Message?
    func setMessage(message : Message , shouldShowThreadCount : Bool = false){
        self.message = message
        self.txtBody.text = message.body
        
        if message.service?.id! == "1989"{
            self.hideTime = true
        }
        imgLogo.backgroundColor = message.service?.color
        
        if shouldShowThreadCount {
            threadCountView.backgroundColor = message.service?.color
            threadCount.text = String(message.messagesInThread)
        } else {
            threadCountView.hidden = true
        }
        
        //bottleneck?
        let textSize = [10,15,20][Settings.textSize]
        let font = UIFont.systemFontOfSize(CGFloat(textSize), weight: UIFontWeightThin)
        txtBody.font = font
        txtTime.font = font
        
        self.txtTime.text = message.timestamp.shortTimeAgoSinceNow()
        imgLogo.setImage(message.logo, forState: .Normal)
        var serviceColor : UIColor = message.isFromUser ? Constants.appBrandColor : (message.service?.color)!
        txtName.textColor = serviceColor
  
        if(message.isFromUser){
            //self.txtUsername.text = "@" + Core.Username
            self.txtName.text = Core.Username
            
            var target = matchesForRegexInText("(?:^|\\s|$|[.])@[\\p{L}0-9_]*", text: message.body)
            if(target.count > 0){
                let name = target[0]
                let services = Core.Services.filter({"@"+$0.username == name})
                if(services.count > 0){
                    txtBody.mentionColor = (services[0].color)
                    txtBody.URLColor = (services[0].color)
                    serviceColor = services[0].color
                }
                else{
                    txtBody.mentionColor = Constants.appBrandColor
                    txtBody.URLColor = Constants.appBrandColor
                    
                }
            }
        }
        else{
            //self.txtUsername.text = "@" + (message.service?.name)!
            self.txtName.text = message.service?.name
            txtBody.mentionColor = Constants.appBrandColor
            txtBody.URLColor = Constants.appBrandColor
        }
        
        
        self.payloadContainer.subviews.forEach { $0.removeFromSuperview() }

        if !self.shouldShowText {
            self.payloadContainerHeight.constant = 0
            return
        }
        
        self.payloadContainer.backgroundColor = currentTheme.backgroundColor
        
       
        
        if(message.type == .Text || message.type == .Prompt){
            self.payloadContainerHeight.constant = 0
        }
        else if(message.type == .Table){
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
        else if(message.type == .Image){
            self.payloadContainerHeight.constant = 180
            if (message.payload as! ImagePayload).URL.isEmpty {
                return
            }
            
            let imageView = UIImageView()

            Alamofire.request(.GET, (message.payload as! ImagePayload).URL)
                .responseImage { response in                    
                    if let image = response.result.value {
                        self.img = image
                        imageView.image = image.af_imageAspectScaledToFillSize(CGSize(width: 250, height: 150))
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
        else if(message.type == .BarChart){
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
            
            dataSet.colors = [serviceColor]
            let data = BarChartData(xVals: payload.labels, dataSet: dataSet)
            view.data = data
            view.tintColor = serviceColor
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
        else if (message.type == .RequestAuth){
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
        else if(message.type == .CardList){
            
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
                        make.leading.equalTo(77)
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
        else if(message.type == .Progress) {
            let progressView = ProgressView()
            self.payloadContainerHeight.constant = 90
            self.payloadContainer.addSubview(progressView)
            
            let payload = message.payload as! ProgressPayload
            
            progressView.snp_makeConstraints(closure: { make in
                make.leading.trailing.top.bottom.equalTo(0)
            })
            
            progressView.setProgressValues(payload.min, max: payload.max, value: payload.value)
            progressView.progressBar.backgroundColor = message.service?.color
            progressView.valueBackground.backgroundColor = message.service?.color
            progressView.barView.layer.borderColor = message.service?.color.CGColor
            progressView.barView.layer.borderWidth = 1
        }
        else if(message.type == .ImageUpload){
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
        else if(message.type == .Sheets){
            let payload = message.payload as! SheetsPayload
            if payload.sheets.count == 0 {
                return
            }
            let height = payload.sheets[0].entries.reduce(0){$0 + $1.size()} + 10
            self.payloadContainerHeight.constant = CGFloat(height)
            
            let sheetsView = SheetsView()
            sheetsView.delegate = self
            sheetsView.loadSheets(payload.sheets, color: serviceColor)
            self.payloadContainer.addSubview(sheetsView)
            sheetsView.snp_makeConstraints(closure: { (make)->Void in
                make.leading.equalTo(-67)
                make.trailing.equalTo(19)
                make.top.bottom.equalTo(0)
            })
        }
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
        vc.payload = payload
        vc.service = message?.service
        self.parentViewController?.presentViewController(vc, animated: true, completion: nil)
        
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
