//
//  AutoCompletionServiceCell.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 22/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class AutoCompletionServiceCell: UICollectionViewCell {
    @IBOutlet weak var backgroundColorView: UIView!

    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var txtName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
//        imgLogo.layer.shadowColor = UIColor.blackColor().CGColor
//        imgLogo.layer.shadowOffset = CGSizeZero
//        imgLogo.layer.shadowOpacity = 0.25
//        imgLogo.layer.shadowRadius = 5
        backgroundColorView.layer.masksToBounds = true
    }
    
    func loadService(service : Service) {
        txtName.text = service.name.uppercaseString
        imgLogo.image = UIImage(named: service.username)
        backgroundColorView.backgroundColor = service.color
        txtName.textColor = service.color
    }
    
}
