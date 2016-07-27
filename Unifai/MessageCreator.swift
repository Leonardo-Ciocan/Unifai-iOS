//
//  MessageCreator.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 28/05/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

enum Position {
    case Top
    case Bottom
}

@IBDesignable class MessageCreator: UIView , UITextFieldDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate , ActionPickerDelegate , CreatorAssistantDelegate {
    
    var suggestions : [String] = [
        "@weather what's the weather like in London?",
        "@travel what's the cheapest flight from London to France?",
        "@budget total for vacations",
        "@budget all expenses",
        "@reddit front page"
    ]
    
    
    @IBOutlet weak var btnSendTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var btnImage: UIButton!
    
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var creatorDelegate : MessageCreatorDelegate?
    
    @IBOutlet weak var txtMessage: MessageCreatorTextView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var backgroundColorView: UIView!

    @IBInspectable var isTop : Bool = true
    let imagePicker = UIImagePickerController()
    
    let border = CALayer()
    var assistant : CreatorAssistant? {
        didSet {
            guard assistant != nil else { return }
            print("Setting delegate")
            assistant!.delegate = self
        }
    }
    
    var parentViewController : UIViewController?

    override func drawRect(rect: CGRect) {

        border.backgroundColor = currentTheme.shadeColor.CGColor
        border.frame = CGRect(x: 15, y: isTop ? self.frame.height - 1 : 0, width: self.frame.width-30, height: 1)
        self.layer.addSublayer(border)
        super.drawRect(rect)
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib ()
    }
    
    @IBOutlet weak var imageLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var textBoxLeftConstraint: NSLayoutConstraint!
    func loadViewFromNib() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "MessageCreator", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(view);
        
        //view.backgroundColor = currentTheme.backgroundColor
        self.backgroundColor = currentTheme.backgroundColor
        
       txtMessage.addTarget(
            self,
            action: #selector(textChanged),
            forControlEvents: UIControlEvents.EditingChanged
        )
        txtMessage.delegate = self
        txtMessage.attributedPlaceholder = NSAttributedString(string:suggestions[0],
                                                             attributes:[NSForegroundColorAttributeName: currentTheme.secondaryForegroundColor])
        NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: #selector(nextSuggestion), userInfo: nil, repeats: true)
        imagePicker.delegate = self
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        imageView.layer.borderWidth=0
        imageView.hidden = true
        
        self.shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.shadowView.layer.shadowRadius = 5.0
        self.shadowView.layer.shadowOpacity = 0.1
        btnAction.tintColor = currentTheme.foregroundColor
        btnImage.tintColor = currentTheme.foregroundColor
        btnAction.setImage(btnAction.currentImage!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        btnImage.setImage(btnImage.currentImage!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        
        txtMessage.layer.borderColor = currentTheme.foregroundColor.CGColor
        txtMessage.textColor = currentTheme.foregroundColor
        txtMessage.backgroundColor = currentTheme.shadeColor
        
        
        self.backgroundColorView.backgroundColor = currentTheme.backgroundColor
    }
    
    func selectedService(service: Service? , selectedByTapping : Bool) {
        if let service = service {
            self.creatorDelegate?.didSelectService(service)
            UIView.animateWithDuration(1, animations: {
                self.backgroundColorView.backgroundColor = service.color
                self.btnSend.tintColor = UIColor.whiteColor()
                self.btnImage.tintColor = UIColor.whiteColor()
                self.btnAction.tintColor = UIColor.whiteColor()
                self.txtMessage.textColor = UIColor.whiteColor()
            })
            
            if selectedByTapping {
                txtMessage.text = "@" + service.username + " "
            }
        }
        else {
            self.creatorDelegate?.didSelectService(service)
            UIView.animateWithDuration(1, animations: {
                self.backgroundColorView.backgroundColor = currentTheme.backgroundColor
                self.btnSend.tintColor = Constants.appBrandColor
                self.btnImage.tintColor = currentTheme.foregroundColor
                self.btnAction.tintColor = currentTheme.foregroundColor
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
        suggestionIndex = (suggestionIndex + 1) % suggestions.count
        txtMessage.attributedPlaceholder = NSAttributedString(string:suggestions[suggestionIndex],
                                                               attributes:[NSForegroundColorAttributeName: currentTheme.secondaryForegroundColor])
    }
    
    @IBAction func runAction(sender: AnyObject) {
        let picker = ActionPickerViewController()
        picker.delegate = self
        self.parentViewController?.presentViewController(picker, animated: true, completion: nil)
    }
    
    func selectedAction(message: String) {
        txtMessage.text = message
        textChanged(self)
    }
    
    func setLoading(loading:Bool){
        if loading {
            activityIndicator.startAnimating()
            btnSend.hidden = true
            activityIndicator.hidden = false
        }
        else{
            activityIndicator.stopAnimating()
            btnSend.hidden = false
            activityIndicator.hidden = true
        }
    }
    
    @IBAction func send(sender: AnyObject) {
        guard creatorDelegate != nil else {return}
        
        creatorDelegate?.sendMessage(txtMessage.text!)
        txtMessage.text = ""
        txtMessage.resignFirstResponder()
        btnSend.tintColor = Constants.appBrandColor
        btnImage.tintColor = currentTheme.foregroundColor
        btnAction.tintColor = currentTheme.foregroundColor
        selectedService(nil, selectedByTapping: false)
        setLoading(true)
    }
    
    @IBAction func textChanged(sender: AnyObject) {
        //assistant?.autocompleteFor(txtMessage.text!)
        assistant?.autocompleteFor(txtMessage.text!)
                
//        
//        var target = matchesForRegexInText("(?:^|\\s|$|[.])@[\\p{L}0-9_]*", text: txtMessage.text)
//        if(target.count > 0){
//            let name = target[0]
//            let services = Core.Services.filter({"@"+$0.username == name})
//            if(services.count > 0){
//                UIView.animateWithDuration(0.6, animations: {
//                    
//                    
//                    self.btnSend.tintColor = (services[0].color)
//                    self.btnAction.tintColor = services[0].color
//                    self.btnImage.tintColor = services[0].color
//                    
//                })
//            }
//            else{
//                btnSend.tintColor = Constants.appBrandColor
//                btnAction.tintColor = currentTheme.foregroundColor
//                btnImage.tintColor = currentTheme.foregroundColor
//            }
//        }
    }
    
    @IBAction func pickImage(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary

        self.textBoxLeftConstraint.constant = 120
        self.imageLeftConstraint.constant = 15
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations:
            { [weak self] in
                self!.layoutIfNeeded()
            }
            , completion: { _ in
                self.parentViewController!.presentViewController(self.imagePicker, animated: true, completion: nil)
            })
        
        
    }
   
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        parentViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFill
            imageView.image = pickedImage
            
            
        }
        
        self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.creatorDelegate?.didStartWriting()
        assistant?.serviceAutoCompleteView.collectionView.reloadData()
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
}
