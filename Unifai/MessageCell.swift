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

class MessageCell: UITableViewCell {
    
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
        threadCountView.layer.borderColor = UIColor.whiteColor().CGColor
        
    }
    
    
    
    var message : Message?
    func setMessage(message : Message , shouldShowThreadCount : Bool = false){
        self.message = message
        self.txtBody.text = message.body
        
        if message.service?.id! == "1989"{
            self.hideTime = true
        }
        txtName.textColor = message.service?.color.darkerColor()
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
        
        if(message.type == .Text){
            self.payloadContainerHeight.constant = 0
        }
        else if(message.type == .Table){
            self.payloadContainerHeight.constant = CGFloat((message.payload as! TablePayload).rows.count) * 50 + 50
            let tableView = TablePayloadView()
            self.payloadContainer.addSubview(tableView)
            tableView.snp_makeConstraints(closure: { (make)->Void in
                make.trailing.leading.equalTo(0)
                make.bottom.top.equalTo(0)
            })
            tableView.loadData(message.payload as! TablePayload)
            
           
        }
        else if(message.type == .Image){
            self.payloadContainerHeight.constant = 180
            var url:NSURL? = NSURL(string: (message.payload as! ImagePayload).URL)
            var data:NSData? = NSData(contentsOfURL : url!)
            var image = UIImage(data : data!)
            
            self.img = image
            
            let imageView = UIImageView(image: image)
            
            self.imgView = imageView
            
            imageView.contentMode = .ScaleAspectFit
            self.payloadContainer.addSubview(imageView)
            imageView.snp_makeConstraints(closure: { (make)->Void in
                make.trailing.leading.equalTo(0)
                make.bottom.top.equalTo(0)
            })
            
            
        }
        else if(message.type == .BarChart){
            self.payloadContainerHeight.constant = 180
            
            let view = BarChartView()
           
            var yvals : [BarChartDataEntry] = []
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
            view.leftAxis.startAtZeroEnabled = true
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
    }
    
    func onCardTapped(recon:UITapGestureRecognizer){
        let view = recon.view as! CardView
        let svc = SFSafariViewController(URL: NSURL(string: view.navigateURL)!)
        self.parentViewController!.presentViewController(svc, animated: true, completion: nil)
    }
    
    func onTap(recon:UITapGestureRecognizer){
        var payload = message?.payload as! RequestAuthPayload
        print("logging in")
//        let oauthswift = OAuth2Swift(
//            consumerKey:   payload.clientID,
//            consumerSecret: payload.secret,
//            authorizeUrl:   payload.url,
//            responseType:   "code"
//        )
//        oauthswift.authorize_url_handler = SafariURLHandler(viewController: parentViewController!)
//        oauthswift.allowMissingStateCheck = true
//        oauthswift.authorizeWithCallbackURL(
//            NSURL(string: "http://127.0.0.1:8000/callback" )!,
//            scope: payload.scope, state:"",
//            success: { credential, response, parameters in
//                print(credential)
//                print(response)
//            },
//            failure: { error in
//                print(error.localizedDescription)
//            }
//        )
        
        let vc = AuthViewController()
        vc.payload = payload
        vc.service = message?.service
        self.parentViewController?.presentViewController(vc, animated: true, completion: nil)
        
    }

    
}
