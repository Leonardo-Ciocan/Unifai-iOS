//
//  SignupViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 01/05/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

   
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    
    @IBAction func signup(sender: AnyObject) {
        Unifai.signup(txtUsername.text!, email: txtEmail.text!, password: txtPassword.text!, completion: { success in
            Unifai.login(self.txtUsername.text!, password: self.txtPassword.text!, completion: { 
                token in
                NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.performSegueWithIdentifier("auth" , sender: self)
            })
        })
    }
}
