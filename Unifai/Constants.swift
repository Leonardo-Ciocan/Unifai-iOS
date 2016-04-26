//
//  Constants.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 26/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation
import UIKit

class Constants{
    static let appBrandColor = UIColor(red: 0.741, green: 0.404, blue: 0.878, alpha: 1.00)
    
    static let urlRoot = "http://127.0.0.1:8000/"
    static let urlThread = urlRoot + "message/";
    static let urlFeed = urlRoot + "feed/";
    static let urlLogin = urlRoot + "api-token-auth/";
    static let urlServices = urlRoot + "services/all/";
    static let urlMessage = urlRoot + "message/";
}