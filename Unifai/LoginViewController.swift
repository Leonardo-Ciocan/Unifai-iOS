//
//  LoginViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 26/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
import AlertOnboarding
class LoginViewController: UIViewController , UITextFieldDelegate{

    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        
        self.view.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil);
        
        
    }
    
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    func keyboardWillShow(sender: NSNotification) {
        var info = sender.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.logoHeight.constant = 0
        })
    }
    func keyboardWillHide(sender: NSNotification) {
        var info = sender.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.logoHeight.constant = 215
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        //NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
        if NSUserDefaults.standardUserDefaults().stringForKey("token") != nil{
            performSegueWithIdentifier("auth", sender: self)
        }
        else{
            txtPassword.delegate = self
            txtLogin.delegate = self
            self.view.hidden = false
            
            var arrayOfImage = ["logoWithSlogan", "example1", "schedules","actions"]
            var arrayOfTitle = [
                "UNIF(AI)",
                "Your services work toghether",
                "SCHEDULES",
                "ACTIONS"]
            var arrayOfDescription = ["All your services , 1 interface",
                                      "Simply mention the service with @ and you're ready to converse with it",
                                      "Schedule messages so you that you don't even have to type",
                                      "Make buttons for common things you do."]
            
            //Simply call AlertOnboarding...
            var alertView = AlertOnboarding(arrayOfImage: arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription)
            
            alertView.colorButtonText = Constants.appBrandColor
            alertView.colorButtonBottomBackground = UIColor(red: 0, green: 0, blue: 0, alpha: 0.01)
            
            alertView.colorTitleLabel = Constants.appBrandColor
            alertView.colorCurrentPageIndicator = Constants.appBrandColor
            
            alertView.purcentageRatioWidth = 0.9
            alertView.purcentageRatioHeight = 0.9
            
            //... and show it !
            alertView.show()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == txtLogin){
            txtPassword.becomeFirstResponder()
        }
        else{
            txtPassword.resignFirstResponder()
        }
        
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