//
//  Message.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 26/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

enum MessageType{
    case Text , Table , Image
}

class Message {
    var body : String
    var type : MessageType
    var payload : Payload?
    var service : Service?
    var threadID : String?
    
    
    var isFromUser : Bool {
        get{
            return service == nil
        }
    }
    
    
    
    var logo : UIImage {
        get{
            if(isFromUser){
                return UIImage(named:"user")!
            }
            else{
                return UIImage(named: (service?.username)!)!
            }
        }
    }
    
    init(body : String,
         type : MessageType,
         payload : Payload?){
            
        self.body = body
        self.type = type
        self.payload = payload
    }
    
    init(body : String,
        type : MessageType,
        payload : Payload?,
        service : Service){
            
            self.body = body
            self.type = type
            self.payload = payload
            self.service = service
    }
    
    init(json : JSON){
        let body = json["content"].string
        let service = json["service_id"].string
        let thread = json["thread_id"].number?.stringValue
        
        print(service)
        self.body = body!
        self.type = .Text
        self.service = Core.Services.filter({
            s in
            return s.username == service
        }).first
        self.threadID = thread
    }
}