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

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtUsername: UILabel!
    @IBOutlet weak var txtBody: ActiveLabel!
    @IBOutlet weak var imgLogo: UIButton!
    @IBOutlet weak var txtTime: UILabel!
    
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
    
    func setMessage(message : Message){
        self.txtBody.text = message.body
        
        if(message.isFromUser){
            //self.txtUsername.text = "@" + Core.Username
            self.txtName.text = Core.Username
            
            var target = matchesForRegexInText("(?:^|\\s|$|[.])@[\\p{L}0-9_]*", text: message.body)
            if(target.count > 0){
                let name = target[0]
                let services = Core.Services.filter({"@"+$0.username == name})
                if(services.count > 0){
                    txtBody.mentionColor = (services[0].color)
                }
                else{
                    txtBody.mentionColor = Constants.appBrandColor
                }
            }
        }
        else{
            //self.txtUsername.text = "@" + (message.service?.name)!
            self.txtName.text = message.service?.name
            txtBody.mentionColor = Constants.appBrandColor
        }
        
        self.txtTime.text = message.timestamp.shortTimeAgoSinceNow()
        imgLogo.setImage(message.logo, forState: .Normal)
    }
    
}
