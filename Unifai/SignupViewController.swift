//
//  SignupViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 01/05/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController , UITextFieldDelegate {

   
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    
    override func viewDidLoad() {
        txtPassword.delegate = self
        txtEmail.delegate = self
        txtUsername.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    func keyboardWillShow(sender: NSNotification) {
        _ = sender.userInfo!
        //var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.logoHeight.constant = 0
        })
    }
    func keyboardWillHide(sender: NSNotification) {
        _ = sender.userInfo!
        //var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.logoHeight.constant = 215
        })
    }
    
    @IBAction func signup(sender: AnyObject) {
        Unifai.signup(txtUsername.text!, email: txtEmail.text!, password: txtPassword.text!, completion: { success in
            Unifai.login(self.txtUsername.text!, password: self.txtPassword.text!, completion: { 
                token in
                NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.performSegueWithIdentifier("auth" , sender: self)
                }, error: {
                    
                })
            },error: { errors in
                let alert = UIAlertController(title: "Signup error", message: "Can't sign up with those details", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
