import UIKit
import Foundation
import SafariServices
import PKHUD

enum Position {
    case Top
    case Bottom
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
    
    var imageData : NSData?
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
    override func drawRect(rect: CGRect) {
        border.backgroundColor = currentTheme.shadeColor.CGColor
        border.frame = CGRect(x: 15, y: isTop ? self.frame.height - 1 : 0, width: self.frame.width-30, height: 1)
        //self.layer.addSublayer(border)
        super.drawRect(rect)
    }

    var isInPromptMode = false
    var promptService : Service?
    
    @IBOutlet weak var txtPromptMessage: UILabel!
    func enablePromptModeWithSuggestions(service:Service, suggestions:[SuggestionItem] , questionText:String) {
        self.promptService = service
        self.isInPromptMode = true
        self.assistant?.enablePromptModeWithSuggestions(service,suggestions:  suggestions)
        selectedService(service, selectedByTapping: true)
        txtPromptMessage.text = questionText
        [btnAction,btnImage,btnCamera,btnGenius].forEach({ btn in
            
            UIView.animateWithDuration(0.5, animations: {
                btn.alpha = 0
                }, completion : { _ in
                    btn.hidden = true
            })
        })
        txtMessageTopConstraint.constant = 40
        textBoxLeftConstraint.constant = 20
        txtPromptMessage.alpha = 0
        txtPromptMessage.hidden = false
        UIView.animateWithDuration(1, animations: {
            self.txtPromptMessage.alpha = 1
            self.layoutIfNeeded()
        })
        
        
    }
    
    func disablePromptMode() {
        self.isInPromptMode = false
        selectedService(nil, selectedByTapping: false)
        self.assistant?.disablePromptMode()
        [btnAction,btnImage,btnCamera,btnGenius].forEach({ btn in
            btn.hidden = false
            UIView.animateWithDuration(0.5, animations: {
                btn.alpha = 1
                })
        })
        txtMessageTopConstraint.constant = 18
        textBoxLeftConstraint.constant = 52
        txtPromptMessage.alpha = 0
        txtPromptMessage.hidden = false
        UIView.animateWithDuration(1, animations: {
            self.txtPromptMessage.alpha = 0
            self.layoutIfNeeded()
            },completion: {
                _ in
                self.txtPromptMessage.hidden = true
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
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "MessageCreator", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
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
            forControlEvents: UIControlEvents.EditingChanged
        )
        txtMessage.delegate = self
        txtMessage.attributedPlaceholder = NSAttributedString(string:"Ask us anything",
                                                             attributes:[NSForegroundColorAttributeName: currentTheme.secondaryForegroundColor])
        NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: #selector(nextSuggestion), userInfo: nil, repeats: true)
        imagePicker.delegate = self
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        imageView.layer.borderWidth=0
        
        shadowView.backgroundColor = UIColor.clearColor()
        self.shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.shadowView.layer.shadowRadius = 5.0
        self.shadowView.layer.shadowOpacity = 0.1
        
        buttons.forEach({
            $0.tintColor = currentTheme.foregroundColor.colorWithAlphaComponent(0.65)
            $0.imageView?.contentMode = .ScaleAspectFit
            $0.setImage($0.currentImage!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = currentTheme.shadeColor.CGColor
        })
   
        txtMessage.layer.borderColor = currentTheme.foregroundColor.CGColor
        txtMessage.textColor = currentTheme.foregroundColor
        txtMessage.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.035)
        txtMessage.layer.cornerRadius = 5
        txtMessage.layer.masksToBounds = true
        txtMessage.layer.borderColor = currentTheme.shadeColor.CGColor
        txtMessage.layer.borderWidth = 1
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        txtMessage.leftViewMode = .Always
        txtMessage.leftView = leftView
        
        
        btnGenius.tintColor = currentTheme.foregroundColor
        btnGenius.imageView?.contentMode = .ScaleAspectFit
        btnGenius.layer.shadowOffset = CGSizeZero
        btnGenius.layer.shadowColor = UIColor.blackColor().CGColor
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
    
    func sendMessage(message: String) {
            if threadID == nil {
                Unifai.sendMessage(message, completion: { msg in
                    HUD.flash(.Success, delay: 1.0)
                    self.creatorDelegate?.shouldAppendMessage(msg)
                    },error: {
                        HUD.flash(.Error, delay: 1.0)

                        let alert = UIAlertController(title: "Can't send this message", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                        self.parentViewController!.presentViewController(alert, animated: true, completion: nil)
                })
            }
            else {
                Unifai.sendMessage(message,thread:threadID!, completion: { msg in
                    HUD.flash(.Success, delay: 1.0)
                    self.creatorDelegate?.shouldAppendMessage(msg)
                })
            }
    }
    
    func sendMessage(message: String, imageData: NSData) {
        Unifai.sendMessage(message , imageData: imageData, completion: { msg in
            HUD.flash(.Success, delay: 1.0)
            self.creatorDelegate?.shouldAppendMessage(msg)
        })
    }
    
    func sendMessageOrSelectPlaceholder(message:String , imageData: NSData?) {
        let placeholderRanges = TextUtils.getPlaceholderPositionsInMessage(message)
        if placeholderRanges.count > 0 {
            let range = placeholderRanges[0]
            let start = txtMessage.positionFromPosition(txtMessage.beginningOfDocument, offset: range.location)
            guard start != nil else { return }
            let end = txtMessage.positionFromPosition(start!, offset: range.length)
            txtMessage.selectedTextRange = txtMessage.textRangeFromPosition(start!, toPosition: end!)
        }
        else{
            self.creatorDelegate?.shouldAppendMessage(Message(body: txtMessage.text!, type: .Text, payload: nil))
            txtMessage.text = ""
            txtMessage.resignFirstResponder()
            btnSend.tintColor = Constants.appBrandColor
            btnImage.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.65)
            btnAction.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.65)
            btnCamera.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.65)
            txtMessage.tintColor = Constants.appBrandColor
            selectedService(nil, selectedByTapping: false)
            if self.imageData != nil {
                self.imageData = nil
                removeAction(self)
            }
            assistant!.resetAutocompletion()
            
            HUD.show(.Progress)
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
            suggestions = Array(Core.Catalog.values).flatten().map({ $0.message}).filter({ !$0.isEmpty })
        }
        let n = Int(arc4random_uniform(UInt32(suggestions.count)))
        return n < suggestions.count ? suggestions[n] : ""
    }
    
    override func layoutSubviews() {
        btnRemove.layer.cornerRadius = 5
        btnRemove.layer.masksToBounds = true
    }
    
    func selectedService(service: Service? , selectedByTapping : Bool) {
        if let service = service {
            txtMessage.tintColor = UIColor.whiteColor()
            self.creatorDelegate?.shouldThemeHostWithColor(service.color)
            self.btnGenius.setImage(btnGenius.currentImage?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            UIView.animateWithDuration(1, animations: {
                self.backgroundColorView.backgroundColor = service.color
                self.btnSend.tintColor = UIColor.whiteColor()
                self.btnGenius.tintColor = UIColor.whiteColor()
                self.buttons.forEach({
                    $0.tintColor = UIColor.whiteColor()
                })
                self.txtMessage.textColor = UIColor.whiteColor()
            })
            
            if selectedByTapping {
                txtMessage.text = "@" + service.username + " "
            }
        }
        else {
            txtMessage.tintColor = Constants.appBrandColor
            self.creatorDelegate?.shouldRemoveThemeFromHost()
            self.btnGenius.setImage(UIImage(named: geniusSuggestions.count == 0 ? "genius" : "genius_on"), forState: .Normal)
            UIView.animateWithDuration(1, animations: {
                self.backgroundColorView.backgroundColor = UIColor.clearColor()
                self.btnSend.tintColor = Constants.appBrandColor
                self.buttons.forEach({
                    $0.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.65)
                })
                self.txtMessage.textColor = currentTheme.foregroundColor
            })
        }
    }
    
    func didSelectAutocompletion(message: String) {
        txtMessage.text = message
        let placeholderRanges = TextUtils.getPlaceholderPositionsInMessage(message)
        if placeholderRanges.count > 0 {
            let range = placeholderRanges[0]
            let start = txtMessage.positionFromPosition(txtMessage.beginningOfDocument, offset: range.location)
            let end = txtMessage.positionFromPosition(start!, offset: range.length)
            txtMessage.selectedTextRange = txtMessage.textRangeFromPosition(start!, toPosition: end!)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.send(self)
        return false
    }
    
    var suggestionIndex = 0
    func nextSuggestion(){
        //suggestionIndex = (suggestionIndex + 1) % suggestions.count
        txtMessage.attributedPlaceholder = NSAttributedString(string:getRandomCatalogItem(),
                                                               attributes:[NSForegroundColorAttributeName: currentTheme.secondaryForegroundColor])
    }
    
    @IBAction func runAction(sender: AnyObject) {
        let picker = ActionPickerViewController()
        picker.delegate = self
        
        let rootVC = UINavigationController(rootViewController: picker)
        
        rootVC.modalPresentationStyle = .Popover
        let viewForSource = sender as! UIView
        rootVC.popoverPresentationController!.sourceView = viewForSource
        
        // the position of the popover where it's showed
        rootVC.popoverPresentationController!.sourceRect = viewForSource.bounds
        
        // the size you want to display
        rootVC.preferredContentSize = CGSizeMake(300,350)

        self.parentViewController?.presentViewController(rootVC, animated: true, completion: nil)
    }
    
    func selectedAction(message: String) {
        txtMessage.text = message
        textChanged(self)
        self.txtMessage.becomeFirstResponder()
    }
    
    
    @IBAction func send(sender: AnyObject) {
        guard creatorDelegate != nil else {return}
        self.sendMessageOrSelectPlaceholder(txtMessage.text!, imageData: self.imageData)
    }
    
    
    @IBAction func textChanged(sender: AnyObject) {
        assistant?.autocompleteFor(txtMessage.text!)
    }
    
    @IBAction func pickImage(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.modalPresentationStyle = .Popover
        
        self.textBoxLeftConstraint.constant = 135
        self.imageLeftConstraint.constant = 15
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations:
            { [weak self] in
                self!.layoutIfNeeded()
            }
            , completion: { _ in
                let viewForSource = sender as! UIView
                self.imagePicker.popoverPresentationController!.sourceView = viewForSource
                
                // the position of the popover where it's showed
                self.imagePicker.popoverPresentationController!.sourceRect = viewForSource.bounds
                
                // the size you want to display
                self.imagePicker.preferredContentSize = CGSizeMake(200,500)
                self.imagePicker.popoverPresentationController!.delegate = self
                self.parentViewController!.presentViewController(self.imagePicker, animated: true, completion: nil)
            })
    }
    
   
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.textBoxLeftConstraint.constant = 52
        self.imageLeftConstraint.constant = -110
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations:
            { [weak self] in
                self!.layoutIfNeeded()
            }
            , completion: { _ in
                
        })
        parentViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFill
            imageView.image = pickedImage
            if let imageData = UIImagePNGRepresentation(pickedImage) {
                self.imageData = imageData
            }
            updateGeniusSuggestionsLocally()
        }
        
        self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if isInPromptMode &&  promptService != nil {
            creatorDelegate?.shouldThemeHostWithColor((promptService?.color)!)
        }
        self.creatorDelegate?.didStartWriting()
        textChanged(txtMessage)
        assistant?.alpha = 0
        assistant?.hidden = false
        UIView.animateWithDuration(0.5, animations: {
            self.assistant?.alpha = 1
        })
        
        btnSend.alpha = 0
        
        btnSendTrailingConstraint.constant = 15
        UIView.performWithoutAnimation({
            self.txtMessage.layoutIfNeeded()
        })
        UIView.animateWithDuration(0.7, animations: {
            self.layoutIfNeeded()
            self.btnSend.alpha = 1
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.creatorDelegate?.didFinishWirting()
        UIView.animateWithDuration(0.5, animations: {
                self.assistant?.alpha = 0
            }, completion: { _ in
                self.assistant?.hidden = true
        })
        UIView.performWithoutAnimation({
            self.txtMessage.layoutIfNeeded()
        })
        btnSendTrailingConstraint.constant = -25
        UIView.animateWithDuration(0.7, animations: {
            self.layoutIfNeeded()
            self.btnSend.alpha = 0
        })
    }
    
    @IBAction func removeAction(sender: AnyObject) {
        imageView.image = nil
        self.textBoxLeftConstraint.constant = 52
        self.imageLeftConstraint.constant = -110
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations:
            { [weak self] in
                self!.layoutIfNeeded()
            }
            , completion: { _ in
                
        })
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .Camera
        imagePicker.modalPresentationStyle = .Popover
        updateGeniusSuggestionsLocally()
        self.textBoxLeftConstraint.constant = 135
        self.imageLeftConstraint.constant = 15
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations:
            { [weak self] in
                self!.layoutIfNeeded()
            }
            , completion: { _ in
                let viewForSource = sender as! UIView
                self.imagePicker.popoverPresentationController!.sourceView = viewForSource
                
                // the position of the popover where it's showed
                self.imagePicker.popoverPresentationController!.sourceRect = viewForSource.bounds
                
                // the size you want to display
                self.imagePicker.preferredContentSize = CGSizeMake(200,500)
                self.imagePicker.popoverPresentationController!.delegate = self
                self.parentViewController!.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
    }
    
    @IBAction func geniusTapped(sender: AnyObject) {
        guard geniusSuggestions.count > 0 else { return }
        let geniusVC = GeniusViewController()
        geniusVC.groups = self.geniusSuggestions
        geniusVC.delegate = self
        
        let rootVC = UINavigationController(rootViewController: geniusVC)
        rootVC.modalPresentationStyle = .Popover
        rootVC.preferredContentSize = CGSize(width: 300, height: 400)
        let viewForSource = sender as! UIView
        rootVC.popoverPresentationController!.sourceView = viewForSource
        rootVC.popoverPresentationController!.sourceRect = viewForSource.bounds
        self.parentViewController?.presentViewController(rootVC, animated: true, completion: nil)
    }
    
    
    
    var geniusSuggestions : [GeniusGroup] = []
    func updateGeniusSuggestions(threadID : String) {
        Unifai.getGeniusSuggestionForThreadWithID(threadID, completion: { groups in
            self.geniusSuggestions = groups + Genius.computeLocalGeniusSuggestions(withImageData: self.imageData)
            self.btnGenius.setImage(UIImage(named: self.geniusSuggestions.count == 0 ? "genius" : "genius_on"), forState: .Normal)
        })
    }
    
    func updateGeniusSuggestionsLocally() {
        self.geniusSuggestions = Genius.computeLocalGeniusSuggestions(withImageData: self.imageData)
        self.btnGenius.setImage(UIImage(named: self.geniusSuggestions.count == 0 ? "genius" : "genius_on"), forState: .Normal)
    }
    
    func didSelectGeniusSuggestionWithMessage(message: String) {
        self.sendMessage(message)
    }
    
    func didSelectGeniusSuggestionWithClipboardImage() {
        guard let image = UIPasteboard.generalPasteboard().image else { return }
        imageView.contentMode = .ScaleAspectFill
        imageView.image = image
        if let imageData = UIImagePNGRepresentation(image) {
            self.imageData = imageData
        }
        self.textBoxLeftConstraint.constant = 135
        self.imageLeftConstraint.constant = 15
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations:
            {
                self.layoutIfNeeded()
            },completion: nil)

        
    }
    
    func didSelectGeniusSuggestionWithLink(link: String) {
        let svc = SFSafariViewController(URL: NSURL(string: link)!)
        self.parentViewController!.presentViewController(svc, animated: true, completion: nil)
    }
    
    @IBAction func toCatalog(sender: AnyObject) {
        let catalogVC = UIStoryboard(name: "Feed", bundle: nil).instantiateViewControllerWithIdentifier("catalog")
        let rootVC = UINavigationController(rootViewController: catalogVC)
        rootVC.modalPresentationStyle = .Popover
        rootVC.preferredContentSize = CGSize(width: 300, height: 400)
        let viewForSource = sender as! UIView
        rootVC.popoverPresentationController!.sourceView = viewForSource
        rootVC.popoverPresentationController!.sourceRect = viewForSource.bounds
        self.parentViewController?.presentViewController(rootVC, animated: true, completion: nil)
    }
    
    func shouldDismiss() {
        self.txtMessage.resignFirstResponder()
    }
    
}
