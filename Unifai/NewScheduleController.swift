//
//  NewScheduleController.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 29/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation
import Eureka

class NewScheduleController : FormViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("New schedule")
            <<< TextRow("message"){
                $0.title = "Message"
                $0.value = ""
            }
            <<< DateTimeRow("date"){
                $0.minimumDate = NSDate()
                $0.value = NSDate().dateByAddingDays(1)
                $0.title = "Starting"
            }
            <<< PickerRow<String>("repeating") { (row : PickerRow<String>) -> Void in
                row.options = ["Only once" , "Every hour" , "Every day" , "Every week"]
                 row.value = "Only once"
            }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneClick))
    }
    
    func doneClick(sender:UIBarButtonItem){
        let message = self.form.values(includeHidden: true)["message"] as! String
        let date = self.form.values(includeHidden: true)["date"] as! NSDate
        print(self.form.values(includeHidden: true)["repeating"])
        let repeating = ["Only once" , "Every hour" , "Every day" , "Every week"].indexOf(
            self.form.values(includeHidden: true)["repeating"] as! String)
        
       
        Unifai.createSchedule(message, start: date, repeating: repeating!, completion: {_ in self.dismissViewControllerAnimated(true, completion: nil)})
    }
}