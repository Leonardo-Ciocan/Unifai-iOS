//
//  ComposeViewController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 27/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet weak var txtContent: ComposeTextField!
    
    @IBAction func create(sender: AnyObject) {
        Unifai.sendMessage(txtContent.text, completion: { success in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
