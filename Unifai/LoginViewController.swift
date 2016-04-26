//
//  LoginViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 26/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        if NSUserDefaults.standardUserDefaults().stringForKey("token") != nil{
            performSegueWithIdentifier("auth", sender: self)
        }
    }
    
    @IBAction func loginClicked(sender: AnyObject) {
        Unifai.login(txtLogin.text!, password: txtPassword.text! , completion: {
            token in
            NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
}