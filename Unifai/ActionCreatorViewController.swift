import UIKit

protocol ActionCreatorDelegate {
    func didCreateAction(_ action: Action)
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
        txtName.tintColor = UIColor.white
        txtMessage.tintColor = UIColor.white
        changeColor(UIColor.gray.lightenColor(0.05))
        self.navigationController?.navigationController?.navigationBar.isTranslucent = false
        
        let leftView1 = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        txtName.leftViewMode = .always
        txtName.leftView = leftView1
        
        let leftView2 = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        txtMessage.leftViewMode = .always
        txtMessage.leftView = leftView2
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.createTapped(self)
        return true
    }
    
    func changeColor(_ color:UIColor) {
        UIView.animate(withDuration: 0.5, animations: {
            self.txtName.backgroundColor = color.darkenColor(0.05)
            self.txtMessage.backgroundColor = color.darkenColor(0.05)
            self.view.backgroundColor = color
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let color = TextUtils.extractServiceColorFrom(txtMessage.text!)
        changeColor( color ?? UIColor.gray.lightenColor(0.05) )
    }

    @IBAction func textChanged(_ sender: AnyObject) {
        let color = TextUtils.extractServiceColorFrom(txtMessage.text!)
        changeColor( color ?? UIColor.gray.lightenColor(0.05) )
    }
    
    @IBAction func createTapped(_ sender: AnyObject) {
        let placeholderRanges = TextUtils.getPlaceholderPositionsInMessage(txtMessage.text!)
        if placeholderRanges.count > 0 {
            let range = placeholderRanges[0]
            let start = txtMessage.position(from: txtMessage.beginningOfDocument, offset: range.location)
            guard start != nil else { return }
            let end = txtMessage.position(from: start!, offset: range.length)
            txtMessage.selectedTextRange = txtMessage.textRange(from: start!, to: end!)
        }
        else{
            Unifai.createAction(txtMessage.text! , name: txtName.text! , completion: {
                self.delegate?.didCreateAction(Action(message: self.txtMessage.text!, name: self.txtName.text!))
                self.dismiss(animated: true, completion: nil)
                },error: {
                    let dialog = UIAlertController(title: "Can't create action", message: "You need to enter a valid message and name", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                    dialog.addAction(cancel)
                    self.present(dialog, animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
