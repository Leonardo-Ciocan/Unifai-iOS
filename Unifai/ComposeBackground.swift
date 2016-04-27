//
//  ComposeBackground.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 27/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class ComposeBackground: UIView {
    override func drawRect(rect: CGRect) {
        self.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        self.layer.borderWidth = 1.0
        //self.layer.cornerRadius = 5
    }
}
