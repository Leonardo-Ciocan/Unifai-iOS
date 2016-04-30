//
//  ComposeViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 27/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController , UITextViewDelegate {

    @IBOutlet weak var txtContent: ComposeTextField!
    
    override func viewDidLoad() {
        txtContent.delegate = self
    }
    
    func textViewDidChange(textView: UITextView) {
        var target = matchesForRegexInText("(?:^|\\s|$|[.])@[\\p{L}0-9_]*", text: txtContent.text)
        if(target.count > 0){
            let name = target[0]
            let services = Core.Services.filter({"@"+$0.username == name})
            if(services.count > 0){
                self.view.tintColor = (services[0].color)
            }
            else{
                self.view.tintColor = Constants.appBrandColor
            }
        }
    }
    
    
    @IBAction func create(sender: AnyObject) {
        
        var target = matchesForRegexInText("(?:^|\\s|$|[.])@[\\p{L}0-9_]*", text: txtContent.text)
        if(target.count > 0){
            let name = target[0]
            let services = Core.Services.filter({"@"+$0.username == name})
            if(services.count > 0){
                Unifai.sendMessage(txtContent.text, completion: { success in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
            else{
                

            }
        }
        else{
            let alert = UIAlertController(title: "Can't send this message", message: "You need to mention a service , for example @skyscanner", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                switch action.style{
                case .Default:
                    print("default")
                    
                case .Cancel:
                    print("cancel")
                    
                case .Destructive:
                    print("destructive")
                }
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
