import UIKit
import PKHUD

class LoginViewController: UIViewController , UITextFieldDelegate{
    @IBOutlet weak var btnSignup: UIButton!

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        
        self.view.tintColor = UIColor.white
        self.view.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        btnLogin.layer.backgroundColor = UIColor.white.withAlphaComponent(0.15).cgColor
        btnLogin.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        btnLogin.layer.borderWidth = 0
        btnLogin.layer.cornerRadius = 5
        btnLogin.layer.masksToBounds = true
        
        btnSignup.layer.backgroundColor = UIColor.white.withAlphaComponent(0.15).cgColor
        btnSignup.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        btnSignup.layer.borderWidth = 1

        txtLogin.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 10, height: 0))
        txtLogin.leftView?.backgroundColor = UIColor.clear
        txtLogin.layer.cornerRadius = 5
        txtLogin.layer.masksToBounds = true
        txtLogin.leftViewMode = .always
        txtLogin.attributedPlaceholder = NSAttributedString(string:"Username",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
        

        txtPassword.leftViewMode = .always
        txtPassword.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 10, height: 0))
        txtPassword.layer.cornerRadius = 5
        txtPassword.layer.masksToBounds = true
        txtPassword.attributedPlaceholder = NSAttributedString(string:"Password",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
        
        
        if UserDefaults.standard.string(forKey: "token") != nil{
            Core.populateAll(withCallback: {
                self.performSegue(withIdentifier: "auth", sender: self)
                },error: { status in
                    HUD.show(HUDContentType.label("Can't log in right now"))
                    PKHUD.sharedHUD.hide(afterDelay: 2.0)
                    self.view.isHidden = false
            })
        }
    }
    
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    func keyboardWillShow(_ sender: Notification) {
        _ = (sender as NSNotification).userInfo!
        //var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        self.logoHeight.constant = 0
//        UIView.animateWithDuration(0.5, animations: { () -> Void in
//            self.view.layoutIfNeeded()
//        })
    }
    func keyboardWillHide(_ sender: Notification) {
        _ = (sender as NSNotification).userInfo!
        //var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        
//        UIView.animateWithDuration(0.5, animations: { () -> Void in
//            self.logoHeight.constant = 215
//        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
        if UserDefaults.standard.string(forKey: "token") != nil{
            
        }
        else{
            txtPassword.delegate = self
            txtLogin.delegate = self
            self.view.isHidden = false
            
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == txtLogin){
            txtPassword.becomeFirstResponder()
        }
        else{
            txtPassword.resignFirstResponder()
            loginClicked(self)
        }
        return true
    }
    
    @IBAction func loginClicked(_ sender: AnyObject) {
        Unifai.login(txtLogin.text!, password: txtPassword.text! , completion: {
            token in
            UserDefaults.standard.setValue(token, forKey: "token")
            UserDefaults.standard.synchronize()
            Core.populateAll(withCallback: {
                self.performSegue(withIdentifier: "auth" , sender: self)
                },error:{ status in
                    HUD.show(HUDContentType.label("Can't log in right now"))
                    PKHUD.sharedHUD.hide(afterDelay: 2.0)
                    self.view.isHidden = false
            })
            
            } , error: {
                let alert = UIAlertController(title: "Login error", message: "That username and password don't match", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
        })
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !(touches.first?.view?.isKind(of: UITextField.self))! {
            view.endEditing(true)
        }
    }
}
