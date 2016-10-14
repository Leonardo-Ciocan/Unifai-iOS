import Foundation
import UIKit
import SwiftyJSON

enum MessageType : Int{
    case text , table , image , barChart , requestAuth , cardList , file , progress , imageUpload, prompt, sheets
}

class Message {
    var id = "0"
    var body : String = ""
    var type : MessageType = .text
    var payload : Payload?
    var service : Service?
    var threadID : String?
    var timestamp : Date = Date()
    var messagesInThread = "1"
    
    
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
                if let username = service?.username{
                    if let image = UIImage(named: username){
                        return image
                    }
                }
                return UIImage()
            }
        }
    }
    
    var color : UIColor {
        get {
            if let service = service {
                return service.color
            }
            else{
                return Constants.appBrandColor
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
        guard
            let body = json["content"].string,
            let service = json["service_id"].string,
            let type = json["type"].number,
            let id = json["id"].number
        else { return }
        
        let thread = json["thread_id"].string

        self.id = String(describing: id)
        let threadCount = json["numberOfMessagesInThread"].numberValue
        self.messagesInThread = String(describing: threadCount == 0 ? 1 : threadCount)
        self.body = body
        self.service = Core.Services.filter{ $0.username == service }.first
        self.threadID = thread
        
        if let time = json["timestamp"].string {
            print(time)
            let formatter = DateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date =  formatter.date(from: time){
                self.timestamp = date
            }
        }
        
        if let data = json["data"].string {
        self.type = MessageType(rawValue:Int(type))!
            switch type {
            case MessageType.Table.rawValue:
                self.payload = TablePayload(data: data)
            case MessageType.Image.rawValue:
                self.payload = ImagePayload(data: data)
            case MessageType.BarChart.rawValue:
                self.payload = BarChartPayload(data: data)
            case  MessageType.RequestAuth.rawValue:
                self.payload = RequestAuthPayload(data: data)
            case MessageType.CardList.rawValue:
                self.payload = CardListPayload(data: data)
            case MessageType.Progress.rawValue:
                self.payload = ProgressPayload(data: data)
            case MessageType.Prompt.rawValue:
                self.payload = PromptPayload(data: data)
            case MessageType.Sheets.rawValue:
                self.payload = SheetsPayload(data: data)
            default:
                break
            }
        }
    }
    
    
    
    
}
