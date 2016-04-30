import Foundation
import SwiftyJSON

class Schedule {
    var content : String
    var startDate : NSDate = NSDate()
    var interval : Int
    var id : String
    
    init(content:String , startDate:NSDate , interval:Int,id:String){
        self.content = content
        self.startDate = startDate
        self.interval = interval
        self.id = id
    }
    
    static let formatter = NSDateFormatter()
    
    init(json:JSON){
        let message = json["message"].stringValue
        let repeating = json["repeating"].numberValue
        let datetime = json["datetime"].stringValue
        let id = json["trigger_id"].numberValue
        
        Schedule.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        Schedule.formatter.locale = enUSPosixLocale
        self.content = message
        self.interval = Int(repeating)
        if let date = Schedule.formatter.dateFromString(datetime){
            self.startDate = date
        }
        self.id = String(id)
    }
}