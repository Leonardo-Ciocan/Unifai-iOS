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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgLogo.layer.cornerRadius = 5
        imgLogo.layer.masksToBounds = true
        
        
//        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
//        tapGestureRecognizer.numberOfTouchesRequired = 1
//        imgLogo.addGestureRecognizer(tapGestureRecognizer)
//        imgLogo.userInteractionEnabled = true
        contentView.userInteractionEnabled = false
    }
    var message : Message?
    func setMessage(message : Message){
        self.message = message
        self.txtBody.text = message.body
        
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

        if(message.type == .Text){
            self.payloadContainerHeight.constant = 10
        }
        else if(message.type == .Table){
            self.payloadContainerHeight.constant = CGFloat((message.payload as! TablePayload).rows.count) * 50 + 50
            let tableView = TablePayloadView()
            self.payloadContainer.addSubview(tableView)
            tableView.snp_makeConstraints(closure: { (make)->Void in
                make.trailing.leading.equalTo(0)
                make.bottom.top.equalTo(0)
            })
            tableView.loadData(message.payload as! TablePayload , colWidth: Int(self.payloadContainer.frame.width / CGFloat((message.payload as! TablePayload).columns.count)))
            
           
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
            
            dataSet.colors = [serviceColor]
            let data = BarChartData(xVals: payload.labels, dataSet: dataSet)
            view.data = data
            view.tintColor = serviceColor
            view.rightAxis.labelTextColor = UIColor.whiteColor()
            view.leftAxis.startAtZeroEnabled = true
            view.borderColor = UIColor.whiteColor()
            view.drawGridBackgroundEnabled = false
            view.legend.enabled = false
            view.gridBackgroundColor = UIColor.whiteColor()
            view.xAxis.drawGridLinesEnabled = false
            view.leftAxis.drawGridLinesEnabled = false
            view.rightAxis.drawGridLinesEnabled = false
            view.drawBordersEnabled = false
            view.xAxis.drawAxisLineEnabled = false
            view.descriptionText = ""
            view.leftAxis.drawAxisLineEnabled = false
            view.rightAxis.drawAxisLineEnabled = false
            view.xAxis.labelPosition = .Bottom
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
            
            
            var recon = UITapGestureRecognizer(target: self, action: #selector(onTap))
            btn.addGestureRecognizer(recon)
            
            
            btn.snp_makeConstraints(closure: { (make)->Void in
                make.trailing.leading.equalTo(0)
                make.height.equalTo(35)
                make.top.equalTo(0)
            })  
        }
        
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
