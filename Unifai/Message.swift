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

enum MessageType : Int{
    case Text , Table , Image
}

class Message {
    var body : String
    var type : MessageType
    var payload : Payload?
    var service : Service?
    var threadID : String?
    var timestamp : NSDate = NSDate()
    
    
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
        let time = json["timestamp"].stringValue
        let data = json["data"].stringValue
        let type = json["type"].number
        
        self.body = body!
        self.service = Core.Services.filter({
            s in
            return s.username == service
        }).first
        self.threadID = thread
        if let date =  NSDate(string: time, formatString: "yyyy-MM-dd HH:mm:ss.SSSSxxx"){
            self.timestamp = date
        }

        self.type = MessageType(rawValue:Int(type!))!
        
        if(type == 1){
            self.payload = TablePayload(data: data)
        }
        
    }
    
    
    
    
}