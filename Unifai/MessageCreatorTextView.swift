//
//  MessageCreatorTextView.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 28/05/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class MessageCreatorTextView: UITextField {

    
    override func draw(_ rect: CGRect) {
        self.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.005).cgColor
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
        self.layer.borderWidth = 1
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: self.self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = UITextFieldViewMode.always
    }
//    
//    let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 5);
//    
//    override func textRectForBounds(bounds: CGRect) -> CGRect {
//        return UIEdgeInsetsInsetRect(bounds, padding)
//    }
//    
//    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
//        return UIEdgeInsetsInsetRect(bounds, padding)
//    }
//    
//    override func editingRectForBounds(bounds: CGRect) -> CGRect {
//        return UIEdgeInsetsInsetRect(bounds, padding)
//    }

}
