//
//  CatalogItem.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 15/07/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation
import SwiftyJSON

class CatalogItem {
    var name = ""
    var message = ""
    
    init(json:JSON){
        if let name = json["name"].string {
            self.name = name
        }
        
        if let message = json["message"].string {
            self.message = message
        }
    }
}