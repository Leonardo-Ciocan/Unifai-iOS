import UIKit
import AlertOnboarding
class LoginViewController: UIViewController , UITextFieldDelegate{
    @IBOutlet weak var btnSignup: UIButton!

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        
        self.view.tintColor = UIColor.whiteColor()
        self.view.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil);
        
        btnLogin.layer.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.15).CGColor
        btnLogin.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.45).CGColor
        btnLogin.layer.borderWidth = 0
        btnLogin.layer.cornerRadius = 5
        btnLogin.layer.masksToBounds = true
        
        btnSignup.layer.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.15).CGColor
        btnSignup.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.35).CGColor
        btnSignup.layer.borderWidth = 1

        txtLogin.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 10, height: 0))
        txtLogin.leftView?.backgroundColor = UIColor.clearColor()
        txtLogin.layer.cornerRadius = 5
        txtLogin.layer.masksToBounds = true
        txtLogin.leftViewMode = .Always
        txtLogin.attributedPlaceholder = NSAttributedString(string:"Username",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.8)])
        

        txtPassword.leftViewMode = .Always
        txtPassword.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 10, height: 0))
        txtPassword.layer.cornerRadius = 5
        txtPassword.layer.masksToBounds = true
        txtPassword.attributedPlaceholder = NSAttributedString(string:"Password",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.8)])
    }
    
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    func keyboardWillShow(sender: NSNotification) {
        _ = sender.userInfo!
        //var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.logoHeight.constant = 0
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    func keyboardWillHide(sender: NSNotification) {
        _ = sender.userInfo!
        //var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
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
            
            let arrayOfImage = ["logoWithSlogan", "example1", "schedules","actions"]
            let arrayOfTitle = [
                "UNIF(AI)",
                "Your services work toghether",
                "SCHEDULES",
                "ACTIONS"]
            let arrayOfDescription = ["All your services , 1 interface",
                                      "Simply mention the service with @ and you're ready to converse with it",
                                      "Schedule messages so you that you don't even have to type",
                                      "Make buttons for common things you do."]
            
            //Simply call AlertOnboarding...
            let alertView = AlertOnboarding(arrayOfImage: arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription)
            
            alertView.colorButtonText = Constants.appBrandColor
            alertView.colorButtonBottomBackground = UIColor(red: 0, green: 0, blue: 0, alpha: 0.01)
            
            alertView.colorTitleLabel = Constants.appBrandColor
            alertView.colorCurrentPageIndicator = Constants.appBrandColor
            
            alertView.purcentageRatioWidth = 0.9
            alertView.purcentageRatioHeight = 0.9
            
            //... and show it !
            //alertView.show()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == txtLogin){
            txtPassword.becomeFirstResponder()
        }
        else{
            txtPassword.resignFirstResponder()
            loginClicked(self)
        }
        
        return true
    }
    
    @IBAction func loginClicked(sender: AnyObject) {
        Unifai.login(txtLogin.text!, password: txtPassword.text! , completion: {
            token in
            NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.performSegueWithIdentifier("auth" , sender: self)
            } , error: {
                let alert = UIAlertController(title: "Login error", message: "That username and password don't match", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}