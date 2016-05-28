//
//  MessageCreator.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 28/05/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

enum Position {
    case Top
    case Bottom
}

@IBDesignable class MessageCreator: UIView , UITextFieldDelegate {

    
    var suggestions : [String] = [
        "@weather what's the weather like in London?",
        "@skyscanner what's the cheapest flight from London to France?",
        "@budget total for vacations",
        "@budget all expenses"
    ]
    
    var creatorDelegate : MessageCreatorDelegate?
    
    @IBOutlet weak var txtMessage: MessageCreatorTextView!
    @IBOutlet weak var btnSend: UIButton!
    
    @IBInspectable var isTop : Bool = true
    
    
    let border = CALayer()
    
    

    override func drawRect(rect: CGRect) {
        self.layer.backgroundColor = UIColor.whiteColor().CGColor
        self.backgroundColor = UIColor.whiteColor()

        border.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).CGColor
        border.frame = CGRect(x: 15, y: isTop ? self.frame.height - 1 : 0, width: self.frame.width-30, height: 1)
        self.layer.addSublayer(border)
        super.drawRect(rect)
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
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "MessageCreator", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(view);
        
       txtMessage.addTarget(
            self,
            action: #selector(textChanged),
            forControlEvents: UIControlEvents.EditingChanged
        )
        txtMessage.delegate = self
        txtMessage.placeholder = self.suggestions[0]
        NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: #selector(nextSuggestion), userInfo: nil, repeats: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        txtMessage.resignFirstResponder()
        self.send(self)
        return false
    }
    
    var suggestionIndex = 0
    func nextSuggestion(){
        suggestionIndex = (suggestionIndex + 1) % suggestions.count
        txtMessage.placeholder = suggestions[suggestionIndex]
    }
    
    
    @IBAction func send(sender: AnyObject) {
        guard creatorDelegate != nil else {return}
        
        creatorDelegate?.sendMessage(txtMessage.text!)
        txtMessage.text = ""
        txtMessage.resignFirstResponder()
        btnSend.tintColor = Constants.appBrandColor
    }
    
    @IBAction func textChanged(sender: AnyObject) {
        var target = matchesForRegexInText("(?:^|\\s|$|[.])@[\\p{L}0-9_]*", text: txtMessage.text)
        if(target.count > 0){
            let name = target[0]
            let services = Core.Services.filter({"@"+$0.username == name})
            if(services.count > 0){
                btnSend.tintColor = (services[0].color)
            }
            else{
                btnSend.tintColor = Constants.appBrandColor
            }
        }
    }
}
