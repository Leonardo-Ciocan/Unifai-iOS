import UIKit
import Foundation
import SafariServices
import PKHUD

enum Position {
    case top
    case bottom
}

@IBDesignable class MessageCreator: UIView , UITextFieldDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate , ActionPickerDelegate , CreatorAssistantDelegate , UIPopoverPresentationControllerDelegate , GeniusViewControllerDelegate {
    
    
    @IBOutlet weak var txtMessageShadow: UIView!
    @IBOutlet weak var btnCatalog: UIButton!
    @IBOutlet weak var btnGenius: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnSendTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var txtMessage: MessageCreatorTextView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var backgroundColorView: UIView!
    
    var creatorDelegate : MessageCreatorDelegate?
    @IBInspectable var isTop : Bool = true
    
    var imageData : Data?
    let imagePicker = UIImagePickerController()
    
    let border = CALayer()
    var assistant : CreatorAssistant? {
        didSet {
            guard assistant != nil else { return }
            assistant!.delegate = self
        }
    }
    
    var threadID : String?
    
    var parentViewController : UIViewController?

    @IBOutlet weak var txtMessageTopConstraint: NSLayoutConstraint!
    override func draw(_ rect: CGRect) {
        border.backgroundColor = currentTheme.shadeColor.cgColor
        border.frame = CGRect(x: 15, y: isTop ? self.frame.height - 1 : 0, width: self.frame.width-30, height: 1)
        //self.layer.addSublayer(border)
        super.draw(rect)
    }

    var isInPromptMode = false
    var promptService : Service?
    
    @IBOutlet weak var txtPromptMessage: UILabel!
    func enablePromptModeWithSuggestions(_ service:Service, suggestions:[SuggestionItem] , questionText:String) {
        self.promptService = service
        self.isInPromptMode = true
        self.assistant?.enablePromptModeWithSuggestions(service,suggestions:  suggestions)
        selectedService(service, selectedByTapping: true)
        txtPromptMessage.text = questionText
        [btnAction,btnImage,btnCamera,btnGenius].forEach({ btn in
            
            UIView.animate(withDuration: 0.5, animations: {
                btn.alpha = 0
                }, completion : { _ in
                    btn.isHidden = true
            })
        })
        txtMessageTopConstraint.constant = 40
        textBoxLeftConstraint.constant = 20
        txtPromptMessage.alpha = 0
        txtPromptMessage.isHidden = false
        UIView.animate(withDuration: 1, animations: {
            self.txtPromptMessage.alpha = 1
            self.layoutIfNeeded()
        })
        
        
    }
    
    func disablePromptMode() {
        self.isInPromptMode = false
        selectedService(nil, selectedByTapping: false)
        self.assistant?.disablePromptMode()
        [btnAction,btnImage,btnCamera,btnGenius].forEach({ btn in
            btn?.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                btn?.alpha = 1
                })
        })
        txtMessageTopConstraint.constant = 18
        textBoxLeftConstraint.constant = 52
        txtPromptMessage.alpha = 0
        txtPromptMessage.isHidden = false
        UIView.animate(withDuration: 1, animations: {
            self.txtPromptMessage.alpha = 0
            self.layoutIfNeeded()
            },completion: {
                _ in
                self.txtPromptMessage.isHidden = true
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    var buttons : [UIButton] = []
    
    @IBOutlet weak var imageLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var textBoxLeftConstraint: NSLayoutConstraint!
    var suggestions : [String] = []

    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "MessageCreator", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view);
        
        //view.backgroundColor = currentTheme.backgroundColor
        view.layer.masksToBounds = true
       buttons.append(btnAction)
       buttons.append(btnImage)
       buttons.append(btnCamera)
       buttons.append(btnCatalog)
        
       txtMessage.addTarget(
            self,
            action: #selector(textChanged),
            for: UIControlEvents.editingChanged
        )
        txtMessage.delegate = self
        txtMessage.attributedPlaceholder = NSAttributedString(string:"Ask us anything",
                                                             attributes:[NSForegroundColorAttributeName: currentTheme.secondaryForegroundColor])
        Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(nextSuggestion), userInfo: nil, repeats: true)
        imagePicker.delegate = self
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        imageView.layer.borderWidth=0
        
        shadowView.backgroundColor = UIColor.clear
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.shadowView.layer.shadowRadius = 5.0
        self.shadowView.layer.shadowOpacity = 0.1
        
        buttons.forEach({
            $0.tintColor = currentTheme.foregroundColor.withAlphaComponent(0.65)
            $0.imageView?.contentMode = .scaleAspectFit
            $0.setImage($0.currentImage!.withRenderingMode(.alwaysTemplate), for: UIControlState())
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = currentTheme.shadeColor.cgColor
        })
   
        txtMessage.layer.borderColor = currentTheme.foregroundColor.cgColor
        txtMessage.textColor = currentTheme.foregroundColor
        txtMessage.backgroundColor = UIColor.black.withAlphaComponent(0.035)
        txtMessage.layer.cornerRadius = 5
        txtMessage.layer.masksToBounds = true
        txtMessage.layer.borderColor = currentTheme.shadeColor.cgColor
        txtMessage.layer.borderWidth = 1
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        txtMessage.leftViewMode = .always
        txtMessage.leftView = leftView
        
        
        btnGenius.tintColor = currentTheme.foregroundColor
        btnGenius.imageView?.contentMode = .scaleAspectFit
        btnGenius.layer.shadowOffset = CGSize.zero
        btnGenius.layer.shadowColor = UIColor.black.cgColor
        btnGenius.layer.shadowRadius = 5
        btnGenius.layer.shadowOpacity = 0.1
        
        //self.backgroundColorView.backgroundColor = currentTheme.backgroundColor
        updateGeniusSuggestionsLocally()

//        txtMessage.layer.cornerRadius = 0
//        txtMessage.layer.shadowPath = UIBezierPath(roundedRect: txtMessage.bounds, cornerRadius: 10).CGPath
//        txtMessage.layer.shadowColor = UIColor.blackColor().CGColor
//        txtMessage.layer.shadowOffset = CGSizeZero
//        txtMessage.layer.shadowOpacity = 0.04
//        txtMessage.layer.shadowRadius = 5
//        txtMessage.layer.borderWidth = 1
//        txtMessage.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.05).CGColor
//        txtMessage.layer.masksToBounds = false
//        txtMessage.layer.backgroundColor = UIColor.clea
        
    }
    
    func sendMessage(_ message: String) {
            if threadID == nil {
                Unifai.sendMessage(message, completion: { msg in
                    HUD.flash(.success, delay: 1.0)
                    self.creatorDelegate?.shouldAppendMessage(msg)
                    },error: {
                        HUD.flash(.error, delay: 1.0)

                        let alert = UIAlertController(title: "Can't send this message", message: "", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.parentViewController!.present(alert, animated: true, completion: nil)
                })
            }
            else {
                Unifai.sendMessage(message,thread:threadID!, completion: { msg in
                    HUD.flash(.success, delay: 1.0)
                    self.creatorDelegate?.shouldAppendMessage(msg)
                })
            }
    }
    
    func sendMessage(_ message: String, imageData: Data) {
        Unifai.sendMessage(message , imageData: imageData, completion: { msg in
            HUD.flash(.success, delay: 1.0)
            self.creatorDelegate?.shouldAppendMessage(msg)
        })
    }
    
    func sendMessageOrSelectPlaceholder(_ message:String , imageData: Data?) {
        let placeholderRanges = TextUtils.getPlaceholderPositionsInMessage(message)
        if placeholderRanges.count > 0 {
            let range = placeholderRanges[0]
            let start = txtMessage.position(from: txtMessage.beginningOfDocument, offset: range.location)
            guard start != nil else { return }
            let end = txtMessage.position(from: start!, offset: range.length)
            txtMessage.selectedTextRange = txtMessage.textRange(from: start!, to: end!)
        }
        else{
            self.creatorDelegate?.shouldAppendMessage(Message(body: txtMessage.text!, type: .text, payload: nil))
            txtMessage.text = ""
            txtMessage.resignFirstResponder()
            btnSend.tintColor = Constants.appBrandColor
            btnImage.tintColor = UIColor.black.withAlphaComponent(0.65)
            btnAction.tintColor = UIColor.black.withAlphaComponent(0.65)
            btnCamera.tintColor = UIColor.black.withAlphaComponent(0.65)
            txtMessage.tintColor = Constants.appBrandColor
            selectedService(nil, selectedByTapping: false)
            if self.imageData != nil {
                self.imageData = nil
                removeAction(self)
            }
            assistant!.resetAutocompletion()
            
            HUD.show(.progress)
            if imageData == nil {
                self.sendMessage(message)
            }
            else {
                self.sendMessage(message, imageData: imageData!)
            }
        }
    }
    
    func getRandomCatalogItem() -> String {
        if suggestions.isEmpty {
            suggestions = Array(Core.Catalog.values).joined().map({ $0.message}).filter({ !$0.isEmpty })
        }
        let n = Int(arc4random_uniform(UInt32(suggestions.count)))
        return n < suggestions.count ? suggestions[n] : ""
    }
    
    override func layoutSubviews() {
        btnRemove.layer.cornerRadius = 5
        btnRemove.layer.masksToBounds = true
    }
    
    func selectedService(_ service: Service? , selectedByTapping : Bool) {
        if let service = service {
            txtMessage.tintColor = UIColor.white
            self.creatorDelegate?.shouldThemeHostWithColor(service.color)
            self.btnGenius.setImage(btnGenius.currentImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            UIView.animate(withDuration: 1, animations: {
                self.backgroundColorView.backgroundColor = service.color
                self.btnSend.tintColor = UIColor.white
                self.btnGenius.tintColor = UIColor.white
                self.buttons.forEach({
                    $0.tintColor = UIColor.white
                })
                self.txtMessage.textColor = UIColor.white
            })
            
            if selectedByTapping {
                txtMessage.text = "@" + service.username + " "
            }
        }
        else {
            txtMessage.tintColor = Constants.appBrandColor
            self.creatorDelegate?.shouldRemoveThemeFromHost()
            self.btnGenius.setImage(UIImage(named: geniusSuggestions.count == 0 ? "genius" : "genius_on"), for: UIControlState())
            UIView.animate(withDuration: 1, animations: {
                self.backgroundColorView.backgroundColor = UIColor.clear
                self.btnSend.tintColor = Constants.appBrandColor
                self.buttons.forEach({
                    $0.tintColor = UIColor.black.withAlphaComponent(0.65)
                })
                self.txtMessage.textColor = currentTheme.foregroundColor
            })
        }
    }
    
    func didSelectAutocompletion(_ message: String) {
        txtMessage.text = message
        let placeholderRanges = TextUtils.getPlaceholderPositionsInMessage(message)
        if placeholderRanges.count > 0 {
            let range = placeholderRanges[0]
            let start = txtMessage.position(from: txtMessage.beginningOfDocument, offset: range.location)
            let end = txtMessage.position(from: start!, offset: range.length)
            txtMessage.selectedTextRange = txtMessage.textRange(from: start!, to: end!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.send(self)
        return false
    }
    
    var suggestionIndex = 0
    func nextSuggestion(){
        //suggestionIndex = (suggestionIndex + 1) % suggestions.count
        txtMessage.attributedPlaceholder = NSAttributedString(string:getRandomCatalogItem(),
                                                               attributes:[NSForegroundColorAttributeName: currentTheme.secondaryForegroundColor])
    }
    
    @IBAction func runAction(_ sender: AnyObject) {
        let picker = ActionPickerViewController()
        picker.delegate = self
        
        let rootVC = UINavigationController(rootViewController: picker)
        
        rootVC.modalPresentationStyle = .popover
        let viewForSource = sender as! UIView
        rootVC.popoverPresentationController!.sourceView = viewForSource
        
        // the position of the popover where it's showed
        rootVC.popoverPresentationController!.sourceRect = viewForSource.bounds
        
        // the size you want to display
        rootVC.preferredContentSize = CGSize(width: 300,height: 350)

        self.parentViewController?.present(rootVC, animated: true, completion: nil)
    }
    
    func selectedAction(_ message: String) {
        txtMessage.text = message
        textChanged(self)
        self.txtMessage.becomeFirstResponder()
    }
    
    
    @IBAction func send(_ sender: AnyObject) {
        guard creatorDelegate != nil else {return}
        self.sendMessageOrSelectPlaceholder(txtMessage.text!, imageData: self.imageData)
    }
    
    
    @IBAction func textChanged(_ sender: AnyObject) {
        assistant?.autocompleteFor(txtMessage.text!)
    }
    
    @IBAction func pickImage(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .popover
        
        self.textBoxLeftConstraint.constant = 135
        self.imageLeftConstraint.constant = 15
        UIView.animate(withDuration: 0.7, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations:
            { [weak self] in
                self!.layoutIfNeeded()
            }
            , completion: { _ in
                let viewForSource = sender as! UIView
                self.imagePicker.popoverPresentationController!.sourceView = viewForSource
                
                // the position of the popover where it's showed
                self.imagePicker.popoverPresentationController!.sourceRect = viewForSource.bounds
                
                // the size you want to display
                self.imagePicker.preferredContentSize = CGSize(width: 200,height: 500)
                self.imagePicker.popoverPresentationController!.delegate = self
                self.parentViewController!.present(self.imagePicker, animated: true, completion: nil)
            })
    }
    
   
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.textBoxLeftConstraint.constant = 52
        self.imageLeftConstraint.constant = -110
        UIView.animate(withDuration: 0.7, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations:
            { [weak self] in
                self!.layoutIfNeeded()
            }
            , completion: { _ in
                
        })
        parentViewController!.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFill
            imageView.image = pickedImage
            if let imageData = UIImagePNGRepresentation(pickedImage) {
                self.imageData = imageData
            }
            updateGeniusSuggestionsLocally()
        }
        
        self.parentViewController!.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if isInPromptMode &&  promptService != nil {
            creatorDelegate?.shouldThemeHostWithColor((promptService?.color)!)
        }
        self.creatorDelegate?.didStartWriting()
        textChanged(txtMessage)
        assistant?.alpha = 0
        assistant?.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.assistant?.alpha = 1
        })
        
        btnSend.alpha = 0
        
        btnSendTrailingConstraint.constant = 15
        UIView.performWithoutAnimation({
            self.txtMessage.layoutIfNeeded()
        })
        UIView.animate(withDuration: 0.7, animations: {
            self.layoutIfNeeded()
            self.btnSend.alpha = 1
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.creatorDelegate?.didFinishWirting()
        UIView.animate(withDuration: 0.5, animations: {
                self.assistant?.alpha = 0
            }, completion: { _ in
                self.assistant?.isHidden = true
        })
        UIView.performWithoutAnimation({
            self.txtMessage.layoutIfNeeded()
        })
        btnSendTrailingConstraint.constant = -25
        UIView.animate(withDuration: 0.7, animations: {
            self.layoutIfNeeded()
            self.btnSend.alpha = 0
        })
    }
    
    @IBAction func removeAction(_ sender: AnyObject) {
        imageView.image = nil
        self.textBoxLeftConstraint.constant = 52
        self.imageLeftConstraint.constant = -110
        UIView.animate(withDuration: 0.7, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations:
            { [weak self] in
                self!.layoutIfNeeded()
            }
            , completion: { _ in
                
        })
    }
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.modalPresentationStyle = .popover
        updateGeniusSuggestionsLocally()
        self.textBoxLeftConstraint.constant = 135
        self.imageLeftConstraint.constant = 15
        UIView.animate(withDuration: 0.7, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations:
            { [weak self] in
                self!.layoutIfNeeded()
            }
            , completion: { _ in
                let viewForSource = sender as! UIView
                self.imagePicker.popoverPresentationController!.sourceView = viewForSource
                
                // the position of the popover where it's showed
                self.imagePicker.popoverPresentationController!.sourceRect = viewForSource.bounds
                
                // the size you want to display
                self.imagePicker.preferredContentSize = CGSize(width: 200,height: 500)
                self.imagePicker.popoverPresentationController!.delegate = self
                self.parentViewController!.present(self.imagePicker, animated: true, completion: nil)
        })
    }
    
    @IBAction func geniusTapped(_ sender: AnyObject) {
        guard geniusSuggestions.count > 0 else { return }
        let geniusVC = GeniusViewController()
        geniusVC.groups = self.geniusSuggestions
        geniusVC.delegate = self
        
        let rootVC = UINavigationController(rootViewController: geniusVC)
        rootVC.modalPresentationStyle = .popover
        rootVC.preferredContentSize = CGSize(width: 300, height: 400)
        let viewForSource = sender as! UIView
        rootVC.popoverPresentationController!.sourceView = viewForSource
        rootVC.popoverPresentationController!.sourceRect = viewForSource.bounds
        self.parentViewController?.present(rootVC, animated: true, completion: nil)
    }
    
    
    
    var geniusSuggestions : [GeniusGroup] = []
    func updateGeniusSuggestions(_ threadID : String) {
        Unifai.getGeniusSuggestionForThreadWithID(threadID, completion: { groups in
            self.geniusSuggestions = groups + Genius.computeLocalGeniusSuggestions(withImageData: self.imageData)
            self.btnGenius.setImage(UIImage(named: self.geniusSuggestions.count == 0 ? "genius" : "genius_on"), for: UIControlState())
        })
    }
    
    func updateGeniusSuggestionsLocally() {
        self.geniusSuggestions = Genius.computeLocalGeniusSuggestions(withImageData: self.imageData)
        self.btnGenius.setImage(UIImage(named: self.geniusSuggestions.count == 0 ? "genius" : "genius_on"), for: UIControlState())
    }
    
    func didSelectGeniusSuggestionWithMessage(_ message: String) {
        self.sendMessage(message)
    }
    
    func didSelectGeniusSuggestionWithClipboardImage() {
        guard let image = UIPasteboard.general.image else { return }
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        if let imageData = UIImagePNGRepresentation(image) {
            self.imageData = imageData
        }
        self.textBoxLeftConstraint.constant = 135
        self.imageLeftConstraint.constant = 15
        UIView.animate(withDuration: 0.7, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations:
            {
                self.layoutIfNeeded()
            },completion: nil)

        
    }
    
    func didSelectGeniusSuggestionWithLink(_ link: String) {
        let svc = SFSafariViewController(url: URL(string: link)!)
        self.parentViewController!.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func toCatalog(_ sender: AnyObject) {
        let catalogVC = UIStoryboard(name: "Feed", bundle: nil).instantiateViewController(withIdentifier: "catalog")
        let rootVC = UINavigationController(rootViewController: catalogVC)
        rootVC.modalPresentationStyle = .popover
        rootVC.preferredContentSize = CGSize(width: 300, height: 400)
        let viewForSource = sender as! UIView
        rootVC.popoverPresentationController!.sourceView = viewForSource
        rootVC.popoverPresentationController!.sourceRect = viewForSource.bounds
        self.parentViewController?.present(rootVC, animated: true, completion: nil)
    }
    
    func shouldDismiss() {
        self.txtMessage.resignFirstResponder()
    }
    
}
