//
//  AutoCompletionServiceCell.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 22/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class AutoCompletionServiceCell: UICollectionViewCell {

    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var txtName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadService(service : Service) {
        txtName.text = service.name
        imgLogo.image = UIImage(named: service.username)
        imgLogo.layer.masksToBounds = true
        imgLogo.layer.cornerRadius = (UIScreen.mainScreen().bounds.width / 4 - 30)/2
        imgLogo.backgroundColor = service.color
        txtName.textColor = service.color
    }
    
}
