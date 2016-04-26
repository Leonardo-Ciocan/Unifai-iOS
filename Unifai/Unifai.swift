//
//  Unifai.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 26/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class Unifai{
    
    static var headers : Dictionary<String,String> {
        get{
            return ["Authorization":"Token " + NSUserDefaults.standardUserDefaults().stringForKey("token")!]
        }
    }
    
    static func getThreads() -> [Message] {
        return []
    }
        
    
    /**
        Logs in user
     
        - Returns: A token
    */
    static func login(username : String , password :String , completion : (String)->() ) {
        Alamofire.request(.POST , Constants.urlLogin ,
            parameters: ["username":username , "password":password])
            .responseJSON{ response in
               let json = JSON(response.result.value!)
               completion(json["token"].string!)
        }
    }
    
    static func getServices(completion : ([Service]) -> ()){
        Alamofire.request(.GET , Constants.urlServices , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data).array
                    var services : [Service] = []
                    for service in json!{
                        services.append(Service(json: service))
                    }
                    completion(services)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    static func getThread(id:String , completion : ([Message])->()) {
        Alamofire.request(.GET , Constants.urlThread , headers:self.headers)
            .responseJSON{ response in
            let json = JSON(response.result.value!).array
            print(json!.count)
        }
    }
    
    static func getFeed(completion : ([Message])->()) {
        
        Alamofire.request(.GET , Constants.urlFeed , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data).array
                    print(json)
                    var messages : [Message] = []
                    for message in json!{
                        messages.append(Message(json: message))
                    }
                    completion(messages)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    static func sendMessage(content : String , completion : ((Bool)->())?){
        Alamofire.request(.POST , Constants.urlMessage ,
            parameters: ["content":content], headers:self.headers)
            .responseJSON{ response in
                print(response)
                
        }
    }
    
}