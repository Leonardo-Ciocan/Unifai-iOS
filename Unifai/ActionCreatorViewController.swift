import UIKit

protocol ActionCreatorDelegate {
    func didCreateAction()
}

class ActionCreatorViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtMessage: UITextField!
    
    var delegate : ActionCreatorDelegate?
    var presetName : String = ""
    var presetMessage : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtName.text = presetName
        txtMessage.text = presetMessage
        txtMessage.delegate = self
        
        self.view.backgroundColor = currentTheme.backgroundColor
        txtName.tintColor = UIColor.whiteColor()
        txtMessage.tintColor = UIColor.whiteColor()
        changeColor(UIColor.grayColor().lightenColor(0.05))
        self.navigationController?.navigationController?.navigationBar.translucent = false
        
        let leftView1 = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        txtName.leftViewMode = .Always
        txtName.leftView = leftView1
        
        let leftView2 = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        txtMessage.leftViewMode = .Always
        txtMessage.leftView = leftView2
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.createTapped(self)
        return true
    }
    
    func changeColor(color:UIColor) {
        UIView.animateWithDuration(0.5, animations: {
            self.txtName.backgroundColor = color.darkenColor(0.05)
            self.txtMessage.backgroundColor = color.darkenColor(0.05)
            self.view.backgroundColor = color
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        let color = TextUtils.extractServiceColorFrom(txtMessage.text!)
        changeColor( color ?? UIColor.grayColor().lightenColor(0.05) )
    }

    @IBAction func textChanged(sender: AnyObject) {
        let color = TextUtils.extractServiceColorFrom(txtMessage.text!)
        changeColor( color ?? UIColor.grayColor().lightenColor(0.05) )
    }
    
    @IBAction func createTapped(sender: AnyObject) {
        let placeholderRanges = TextUtils.getPlaceholderPositionsInMessage(txtMessage.text!)
        if placeholderRanges.count > 0 {
            let range = placeholderRanges[0]
            let start = txtMessage.positionFromPosition(txtMessage.beginningOfDocument, offset: range.location)
            guard start != nil else { return }
            let end = txtMessage.positionFromPosition(start!, offset: range.length)
            txtMessage.selectedTextRange = txtMessage.textRangeFromPosition(start!, toPosition: end!)
        }
        else{
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
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
