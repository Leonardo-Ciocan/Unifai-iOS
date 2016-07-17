//
//  ActionCreatorViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 15/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
protocol ActionCreatorDelegate {
    func createAction( name : String , message : String)
}

class ActionCreatorViewController: UIViewController {
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtMessage: UITextField!
    
    var delegate : ActionCreatorDelegate?
    var presetName : String = ""
    var presetMessage : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtName.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        txtName.layer.cornerRadius = 5
        txtName.layer.borderWidth = 0
        txtMessage.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        txtMessage.layer.cornerRadius = 5
        txtMessage.layer.borderWidth = 0
        txtName.text = presetName
        txtMessage.text = presetMessage
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let color = extractServiceColorFrom(txtMessage.text!)
        UIView.animateWithDuration(0.6, animations: {
            self.view.backgroundColor = color ?? UIColor.blackColor()
        })
    }

    @IBAction func textChanged(sender: AnyObject) {
        print("changing")
        let color = extractServiceColorFrom(txtMessage.text!)
        UIView.animateWithDuration(0.6, animations: {
            self.view.backgroundColor = color ?? UIColor.blackColor()
        })
    }
    
    @IBAction func createTapped(sender: AnyObject) {
        delegate?.createAction(txtName.text!, message: txtMessage.text!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            self.view.backgroundColor = UIColor.blackColor()
            },completion: { _ in
                self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
