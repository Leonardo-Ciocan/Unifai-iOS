//
//  LoginButton.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 01/06/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class LoginButton: UIView {
    
    @IBOutlet weak var loginText: UILabel!
    
    var service : Service?
    
    func setService(_ s : Service){
        service = s
        loginText.text = "Login to " + s.name.uppercased()
        loginText.textColor = service?.color

        //self.backgroundColor = s.color
        //self.layer.backgroundColor = s.color.CGColor
        setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "LoginButton", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = currentTheme.backgroundColor
        
        self.addSubview(view);
    }
    
    
    let newLayer = CALayer()

    override func draw(_ rect: CGRect) {
        //guard service != nil else { return }
        newLayer.borderColor = service?.color.cgColor
        newLayer.borderWidth = 1
        newLayer.cornerRadius = 2
        newLayer.backgroundColor = UIColor.clear.cgColor
        //newLayer.frame = CGRect(x: 10, y: 0, width: self.frame.width-10, height: self.frame.height)
        
        newLayer.cornerRadius = 5
        newLayer.masksToBounds = true
        self.layer.addSublayer(newLayer)

        super.draw(rect)
    }
    
    override func layoutSubviews() {
        newLayer.frame = self.layer.bounds
    }
}
