import UIKit

protocol ActionCreatorDelegate {
    func didCreateAction()
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
        let color = TextUtils.extractServiceColorFrom(txtMessage.text!)
        UIView.animateWithDuration(0.6, animations: {
            self.view.backgroundColor = color ?? UIColor.blackColor()
        })
    }

    @IBAction func textChanged(sender: AnyObject) {
        let color = TextUtils.extractServiceColorFrom(txtMessage.text!)
        UIView.animateWithDuration(0.6, animations: {
            self.view.backgroundColor = color ?? UIColor.blackColor()
        })
    }
    
    @IBAction func createTapped(sender: AnyObject) {
        Unifai.createAction(txtMessage.text! , name: txtName.text! , completion: {
            self.delegate?.didCreateAction()
            self.dismissViewControllerAnimated(true, completion: nil)
            },error: {
                let dialog = UIAlertController(title: "Can't create action", message: "You need to enter a valid message and name", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "OK", style: .Default, handler: nil)
                dialog.addAction(cancel)
                self.presentViewController(dialog, animated: true, completion: nil)
        })
        
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
