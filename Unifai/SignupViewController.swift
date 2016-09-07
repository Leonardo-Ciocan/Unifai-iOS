import UIKit

class SignupViewController: UIViewController , UITextFieldDelegate {

    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
   
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    
    override func viewDidLoad() {
        self.view.tintColor = UIColor.whiteColor()
        
        txtPassword.delegate = self
        txtEmail.delegate = self
        txtUsername.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:  #selector(keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil)
        
        btnSignup.layer.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.15).CGColor
        btnSignup.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.45).CGColor
        btnSignup.layer.borderWidth = 0
        btnSignup.layer.cornerRadius = 5
        btnSignup.layer.masksToBounds = true
        
        btnLogin.layer.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.15).CGColor
        btnLogin.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.35).CGColor
        btnLogin.layer.borderWidth = 1
        
        txtUsername.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 10, height: 0))
        txtUsername.leftView?.backgroundColor = UIColor.clearColor()
        txtUsername.layer.cornerRadius = 5
        txtUsername.layer.masksToBounds = true
        txtUsername.leftViewMode = .Always
        txtUsername.attributedPlaceholder = NSAttributedString(string:"Username",
                                                            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.8)])
        
        
        txtEmail.leftViewMode = .Always
        txtEmail.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 10, height: 0))
        txtEmail.layer.cornerRadius = 5
        txtEmail.layer.masksToBounds = true
        txtEmail.attributedPlaceholder = NSAttributedString(string:"Email",
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
                Core.populateAll(withCallback: {
                    self.performSegueWithIdentifier("auth" , sender: self)
                })
                }, error: {
                    
                })
            },error: { errors in
                var lines = ""
                for item in errors {
                    lines += item.1 + "\n"
                }
                let alert = UIAlertController(title: "Signup error", message: "There are problems with your details:\n" + lines , preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !(touches.first?.view?.isKindOfClass(UITextField))! {
            view.endEditing(true)
        }
    }
}
