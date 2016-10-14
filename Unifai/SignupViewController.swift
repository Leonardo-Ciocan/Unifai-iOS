import UIKit

class SignupViewController: UIViewController , UITextFieldDelegate {

    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
   
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    
    override func viewDidLoad() {
        self.view.tintColor = UIColor.white
        
        txtPassword.delegate = self
        txtEmail.delegate = self
        txtUsername.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        btnSignup.layer.backgroundColor = UIColor.white.withAlphaComponent(0.15).cgColor
        btnSignup.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        btnSignup.layer.borderWidth = 0
        btnSignup.layer.cornerRadius = 5
        btnSignup.layer.masksToBounds = true
        
        btnLogin.layer.backgroundColor = UIColor.white.withAlphaComponent(0.15).cgColor
        btnLogin.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        btnLogin.layer.borderWidth = 1
        
        txtUsername.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 10, height: 0))
        txtUsername.leftView?.backgroundColor = UIColor.clear
        txtUsername.layer.cornerRadius = 5
        txtUsername.layer.masksToBounds = true
        txtUsername.leftViewMode = .always
        txtUsername.attributedPlaceholder = NSAttributedString(string:"Username",
                                                            attributes:[NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
        
        
        txtEmail.leftViewMode = .always
        txtEmail.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 10, height: 0))
        txtEmail.layer.cornerRadius = 5
        txtEmail.layer.masksToBounds = true
        txtEmail.attributedPlaceholder = NSAttributedString(string:"Email",
                                                               attributes:[NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])
        
        txtPassword.leftViewMode = .always
        txtPassword.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 10, height: 0))
        txtPassword.layer.cornerRadius = 5
        txtPassword.layer.masksToBounds = true
        txtPassword.attributedPlaceholder = NSAttributedString(string:"Password",
                                                            attributes:[NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.8)])

    }
    
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    func keyboardWillShow(_ sender: Notification) {
//        _ = sender.userInfo!
//        //var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        
//        UIView.animateWithDuration(0.5, animations: { () -> Void in
//            self.logoHeight.constant = 0
//        })
    }
    func keyboardWillHide(_ sender: Notification) {
//        _ = sender.userInfo!
//        //var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//        
//        UIView.animateWithDuration(0.5, animations: { () -> Void in
//            self.logoHeight.constant = 215
//        })
    }
    
    @IBAction func signup(_ sender: AnyObject) {
        Unifai.signup(txtUsername.text!, email: txtEmail.text!, password: txtPassword.text!, completion: { success in
            Unifai.login(self.txtUsername.text!, password: self.txtPassword.text!, completion: { 
                token in
                UserDefaults.standard.setValue(token, forKey: "token")
                UserDefaults.standard.synchronize()
                Core.populateAll(withCallback: {
                    self.performSegue(withIdentifier: "auth" , sender: self)
                    },error:{status in })
                }, error: {
                    
                })
            },error: { errors in
                var lines = ""
                for item in errors {
                    lines += item.1 + "\n"
                }
                let alert = UIAlertController(title: "Signup error", message: "There are problems with your details:\n" + lines , preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
        })
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
