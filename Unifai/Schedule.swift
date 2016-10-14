import Foundation
import SwiftyJSON

class Schedule {
    var content : String
    var startDate : Date = Date()
    var interval : Int
    var id : String
    
    init(content:String , startDate:Date , interval:Int,id:String){
        self.content = content
        self.startDate = startDate
        self.interval = interval
        self.id = id
    }
    
    static let formatter = DateFormatter()
    
    init(json:JSON){
        let message = json["message"].stringValue
        let repeating = json["repeating"].numberValue
        let datetime = json["datetime"].stringValue
        let id = json["trigger_id"].numberValue
        
        Schedule.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        Schedule.formatter.locale = enUSPosixLocale as Locale!
        self.content = message
        self.interval = Int(repeating)
        if let date = Schedule.formatter.date(from: datetime){
            self.startDate = date
        }
        self.id = String(describing: id)
    }
}
