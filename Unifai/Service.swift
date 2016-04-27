//
//  Service.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 26/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class Service{
    var name : String
    var color : UIColor

    var username : String {
        get{
            return name.lowercaseString
        }
    }
    
    init(name:String , color:UIColor){
        self.name = name
        self.color = color
    }
    
    init(json:JSON){
        let id = json["id"].string
        let name = json["name"].string
        let color = json["colour"].string?.componentsSeparatedByString(",").map{ str in Int(str)}
        
        self.name = name!
        self.color = UIColor(red: CGFloat(color![0]!) / 255.0,
                             green: CGFloat(color![1]!) / 255.0,
                             blue: CGFloat(color![2]!) / 255.0,
                             alpha: 255)
    }
}