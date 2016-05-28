//
//  MessageCreatorTextView.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 28/05/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class MessageCreatorTextView: UITextField {

    
    override func drawRect(rect: CGRect) {
        self.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.005).CGColor
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        self.layer.borderWidth = 1
    }
    
    let padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5);
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

}
