//
//  LoginViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 26/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController , UITextFieldDelegate{

    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        
        self.view.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().stringForKey("token") != nil{
            performSegueWithIdentifier("auth", sender: self)
        }
        else{
            txtPassword.delegate = self
            self.view.hidden = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        txtPassword.resignFirstResponder()
        return true
    }
    
    @IBAction func loginClicked(sender: AnyObject) {
        Unifai.login(txtLogin.text!, password: txtPassword.text! , completion: {
            token in
            NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.performSegueWithIdentifier("auth" , sender: self)
        })
    }
    
}