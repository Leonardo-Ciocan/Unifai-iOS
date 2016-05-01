import Foundation
import SwiftyJSON

class Payload {}

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