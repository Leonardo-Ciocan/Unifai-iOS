import Foundation
import UIKit
import SwiftyJSON

enum MessageType : Int{
    case Text , Table , Image , BarChart
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
        let thread = json["thread_id"].stringValue
        let time = json["timestamp"].stringValue
        let data = json["data"].stringValue
        let type = json["type"].number
        
        self.body = body!
        self.service = Core.Services.filter({
            s in
            return s.username == service
        }).first
        self.threadID = thread
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSxxx"
        if let date =  formatter.dateFromString(time){
            self.timestamp = date
        }

        self.type = MessageType(rawValue:Int(type!))!
        print(type!)
        if(type == 1){
            self.payload = TablePayload(data: data)
        }
        else if(type == 2){
            self.payload = ImagePayload(data: data)
        }
        else if(type == 3){
            self.payload = BarChartPayload(data: data)
        }
        
    }
    
    
    
    
}