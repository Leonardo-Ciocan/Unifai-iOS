//
//  MessageCell.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 26/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtUsername: UILabel!
    @IBOutlet weak var txtBody: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgLogo.layer.cornerRadius = 5
        imgLogo.layer.masksToBounds = true
    }
    
    func setMessage(message : Message){
        self.txtBody.text = message.body
        
        if(message.isFromUser){
            self.txtUsername.text = "@" + Core.Username
            self.txtName.text = Core.Username
        }
        else{
            self.txtUsername.text = "@" + (message.service?.name)!
            self.txtName.text = message.service?.name
        }
        
        imgLogo.image = message.logo
        
    }
    
}
