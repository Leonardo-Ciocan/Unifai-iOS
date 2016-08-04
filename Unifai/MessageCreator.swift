//
//  MessageCreator.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 28/05/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit
import Foundation
import SafariServices

enum Position {
    case Top
    case Bottom
}

@IBDesignable class MessageCreator: UIView , UITextFieldDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate , ActionPickerDelegate , CreatorAssistantDelegate , UIPopoverPresentationControllerDelegate , GeniusViewControllerDelegate {
    
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

    override func drawRect(rect: CGRect) {
        border.backgroundColor = currentTheme.shadeColor.CGColor
        border.frame = CGRect(x: 15, y: isTop ? self.frame.height - 1 : 0, width: self.frame.width-30, height: 1)
        self.layer.addSublayer(border)
        super.drawRect(rect)
    }

    var isInPromptMode = false
    
    func enablePromptModeWithSuggestions(service:Service, suggestions:[SuggestionItem]) {
        self.isInPromptMode = true
        self.assistant?.enablePromptModeWithSuggestions(service,suggestions:  suggestions)
        selectedService(service, selectedByTapping: true)
    }
    
    func disablePromptMode() {
        self.isInPromptMode = false
        selectedService(nil, selectedByTapping: false)
        self.assistant?.disablePromptMode()
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
        self.backgroundColor = currentTheme.backgroundColor
        view.layer.masksToBounds = true
       buttons.append(btnAction)
       buttons.append(btnImage)
       buttons.append(btnCamera)
        
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
            $0.tintColor = currentTheme.foregroundColor
            $0.imageView?.contentMode = .ScaleAspectFit
            $0.setImage($0.currentImage!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            $0.backgroundColor = currentTheme.shadeColor
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 12
        })
        txtMessage.layer.borderColor = currentTheme.foregroundColor.CGColor
        txtMessage.textColor = currentTheme.foregroundColor
        txtMessage.backgroundColor = currentTheme.shadeColor
        
        btnGenius.tintColor = currentTheme.foregroundColor
        btnGenius.imageView?.contentMode = .ScaleAspectFit
        
        self.backgroundColorView.backgroundColor = currentTheme.backgroundColor
    }
    
    func sendMessage(message: String) {
        if threadID == nil {
            Unifai.sendMessage(message, completion: { success in
                self.creatorDelegate?.shouldRefreshData()
                },error: {
                    let alert = UIAlertController(title: "Can't send this message", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.parentViewController!.presentViewController(alert, animated: true, completion: nil)
            })
        }
        else {
            Unifai.sendMessage(message,thread:threadID!, completion: { success in
                self.creatorDelegate?.shouldRefreshData()
            })
        }
        
        
    }
    
    func sendMessage(message: String, imageData: NSData) {
        Unifai.sendMessage(message , imageData: imageData, completion: { success in
            self.creatorDelegate?.shouldRefreshData()
        })
    }
    
    func getRandomCatalogItem() -> String {
        if suggestions.isEmpty {
            suggestions = Array(Core.Catalog.values).flatten().map({ $0.message}).filter({ !$0.isEmpty })
        }
        let n = Int(arc4random_uniform(UInt32(suggestions.count)))
        return n < suggestions.count ? suggestions[n] : ""
    }
    
    override func layoutSubviews() {
        //btnRemove.roundCorners([.BottomLeft,.BottomRight], radius: 10)
        btnRemove.layer.cornerRadius = 5
        btnRemove.layer.masksToBounds = true
    }
    
    func selectedService(service: Service? , selectedByTapping : Bool) {
        if let service = service {
            self.creatorDelegate?.didSelectService(service)
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
            self.creatorDelegate?.didSelectService(service)
            self.btnGenius.setImage(UIImage(named: geniusSuggestions.count == 0 ? "genius" : "genius_on"), forState: .Normal)
            UIView.animateWithDuration(1, animations: {
                self.backgroundColorView.backgroundColor = currentTheme.backgroundColor
                self.btnSend.tintColor = Constants.appBrandColor
                self.buttons.forEach({
                    $0.tintColor = currentTheme.foregroundColor
                })
                self.txtMessage.textColor = currentTheme.foregroundColor
            })
        }
    }
    
    func didSelectAutocompletion(message: String) {
        txtMessage.text = message
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        txtMessage.resignFirstResponder()
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
        if let data = self.imageData {
            self.sendMessage(txtMessage.text!, imageData: data)
        }
        else {
            self.sendMessage(txtMessage.text!)
        }
        txtMessage.text = ""
        txtMessage.resignFirstResponder()
        btnSend.tintColor = Constants.appBrandColor
        btnImage.tintColor = currentTheme.foregroundColor
        btnAction.tintColor = currentTheme.foregroundColor
        btnCamera.tintColor = currentTheme.foregroundColor
        selectedService(nil, selectedByTapping: false)
        if imageData != nil {
            imageData = nil
            removeAction(self)
        }
        assistant!.resetAutocompletion()
    }
    
    
    @IBAction func textChanged(sender: AnyObject) {
        //assistant?.autocompleteFor(txtMessage.text!)
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
        }
        
        self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.creatorDelegate?.didStartWriting()
        textChanged(txtMessage)
        //assistant?.serviceAutoCompleteView.collectionView.reloadData()
        assistant?.alpha = 0
        assistant?.hidden = false
        UIView.animateWithDuration(0.5, animations: {
            self.assistant?.alpha = 1
        })
        
        btnSend.alpha = 0
        btnSendTrailingConstraint.constant = 15
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
    
}
