import Foundation
import SwiftyJSON

class Payload {
    
}

class ImagePayload : Payload {
    var URL = ""
    init(data:String) {
        URL = data
    }
}

class TablePayload : Payload {
    var columns : [String] = []
    var rows : [[String]] = []
    
    init(data:String) {
        let dt = data.dataUsingEncoding(NSUTF8StringEncoding , allowLossyConversion: true)
        let json = JSON(data:dt!)
        let json_columns = json["headings"].arrayValue
        let json_rows = json["rows"].arrayValue
        
        print(json)
        
        for column in 0..<json_columns.count {
            self.columns.append((json_columns[column]).stringValue)
        }
        
        for row in 0..<json_rows.count {
            var current_row : [String] = []
            for value in json_rows[row].array!{
                current_row.append(value.stringValue)
            }
            rows.append(current_row)
        }
    }
}

class BarChartPayload : Payload {
    
    var labels : [String] = []
    var values : [Float]  = []
    
    init(data:String) {
        let dt = data.dataUsingEncoding(NSUTF8StringEncoding , allowLossyConversion: true)
        if let json = JSON(data:dt!).array{
            for item in json{
                self.labels.append(item["label"].stringValue)
                self.values.append(item["value"].floatValue)
            }
        }
    }
}

class RequestAuthPayload : Payload {
    var url = ""
    var clientID = ""
    var secret = ""
    var scope = ""
    
    init(data:String) {
        let dt = data.dataUsingEncoding(NSUTF8StringEncoding , allowLossyConversion: true)
        let json = JSON(data:dt!)
        url = json["url"].stringValue
        clientID = json["client_id"].stringValue
        secret = json["secret"].stringValue
        scope = json["scope"].stringValue
    }
}

class CardListPayloadItem {
    var title : String?
    var imageURL : String?
    var navigateURL : String?
    
    init(json:JSON) {
        title = json["title"].string
        imageURL = json["image_url"].string
        navigateURL = json["navigate_url"].string
    }
}

class CardListPayload : Payload {
    var items : [CardListPayloadItem] = []
    init(data:String) {
        let dt = data.dataUsingEncoding(NSUTF8StringEncoding , allowLossyConversion: true)
        if let json = JSON(data:dt!).array{
            for card in json{
                items.append(CardListPayloadItem(json: card))
            }
        }
    }
}

class ProgressPayload : Payload {
    var min = 0
    var max = 0
    var value = 0
    
    init(data : String ) {
        let dt = data.dataUsingEncoding(NSUTF8StringEncoding , allowLossyConversion: true)
        let json = JSON(data:dt!)
        if let min = json["min"].int {
            self.min = min
        }
        
        if let max = json["max"].int {
            self.max = max
        }
        
        if let value = json["value"].int {
            self.value = value
        }
    }
}

class PromptPayload : Payload {
    var suggestions : [SuggestionItem] = []
    var questionText : String = ""
    
    init(data : String ) {
        let dt = data.dataUsingEncoding(NSUTF8StringEncoding , allowLossyConversion: true)
        let items = JSON(data:dt!)
        if let question = items["question_text"].string {
            self.questionText = question
        }
        if let suggestions = items["suggestions"].array {
            for item in suggestions {
                if let title = item["title"].string {
                    if let subtitle = item["subtitle"].string {
                        if let value = item["value"].string {
                            self.suggestions.append(SuggestionItem(title: title, subtitle: subtitle,value:value))
                        }
                    }
                }
            }
        }
    }
}

class SheetsPayload : Payload {
    var sheets : [Sheet] = []
    init(data:String) {
        let dt = data.dataUsingEncoding(NSUTF8StringEncoding , allowLossyConversion: true)
        if let json = JSON(data:dt!).array{
            for item in json {
                let sheet = Sheet()
                for entry in item["entries"].arrayValue {
                    let type = entry["type"].intValue
                    switch type{
                    case 0:
                        sheet.entries.append(TextSheetEntry(text: entry["text"].stringValue))
                    case 1:
                        sheet.entries.append(TitledSheetEntry(title: entry["title"].stringValue, subtitle: entry["subtitle"].stringValue))
                    case 2:
                        sheet.entries.append(ActionSheetEntry(label: entry["label"].stringValue,action: entry["action"].stringValue, value: entry["value"].stringValue))
                    case 3:
                        sheet.entries.append(ImageSheetEntry(url: entry["url"].stringValue, title: entry["title"].stringValue))
                    default:
                        continue
                    }
                }
                sheets.append(sheet)
                
            }
            
        }
    }
}

