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
                if let token = json["token"].string{
                    completion(token)
                }
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
                    print("getServices failed with error: \(error)")
                }
        }
    }
    
    static func getActions(completion : ([Action]) -> ()){
        Alamofire.request(.GET , Constants.urlAction , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data).array
                    var actions : [Action] = []
                    for action in json!{
                        actions.append(Action(json: action))
                    }
                    completion(actions)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    static func getThread(id:String , completion : ([Message])->()) {
        Alamofire.request(.GET , Constants.urlThread + id , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data).array
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
    
    static func getFeed(completion : ([Message])->()) {
        
        Alamofire.request(.GET , Constants.urlFeed , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data).array
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
    
    static func getDashboard(completion : ([Message])->()) {
        
        Alamofire.request(.GET , Constants.urlDashboard , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data).array
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
    
    static func getProfile(serviceID : String , completion : ([Message])->()) {
        
        Alamofire.request(.GET , Constants.urlServiceProfile + serviceID , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data).array
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
    
    static func getUserProfile(completion : ([Message])->()) {
        
        Alamofire.request(.GET , Constants.urlUserProfile , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data).array
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
    
    static func getDashboardItems(completion : ([String])->()) {
        
        Alamofire.request(.GET , Constants.urlDashboardItems , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data).array
                    var messages : [String] = []
                    for message in json!{
                        if let x = message.string{
                            messages.append(x)
                        }
                    }
                    completion(messages)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    static func setDashboardItems(items : [String], completion : ((Bool)->())?){
        print(items)
        Alamofire.request(.POST , Constants.urlDashboardItems ,
                          parameters: ["queries": items], headers:self.headers)
            .responseJSON{ response in
                completion!(true)
        }
    }
    
    
    static func sendMessage(content : String , completion : ((Bool)->())?){

        Alamofire.request(.POST , Constants.urlMessage ,
            parameters: ["content":content], headers:self.headers)
            .responseJSON{ response in
                completion!(true)
        }
    }
    
    static func createAction(message : String ,name:String, completion : ((Bool)->())?){
        Alamofire.request(.POST , Constants.urlAction ,
            parameters: ["message":message,"name":name], headers:self.headers)
            .responseJSON{ response in
                completion!(true)
        }
    }
    
    static func sendMessage(content : String , thread : String , completion : ((Bool)->())?){
        Alamofire.request(.POST , Constants.urlMessage ,
            parameters: ["content":content , "thread_id" : thread], headers:self.headers)
            .responseJSON{ response in
                completion!(true)
        }
    }
    
    static func deleteThread(thread:String , completion : ((Bool)->())?){
        Alamofire.request(.DELETE , Constants.urlThread + thread , headers:self.headers)
            .responseJSON{ response in
                guard completion != nil else{return}
                completion!(true)
        }
    }
    
    static func getUserInfo(completion : (username:String,email:String)->()) {
        
        Alamofire.request(.GET , Constants.urlUserInfo , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data)
                    
                    completion(username:json["username"].stringValue , email:json["email"].stringValue)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    static func getSchedules( completion : ([Schedule])->()) {
        
        Alamofire.request(.GET , Constants.urlSchedules, headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data).array
                    var schedules : [Schedule] = []
                    for schedule in json!{
                        schedules.append(Schedule(json: schedule))
                    }
                    completion(schedules)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    
                }
        }
    }
    
    static func createSchedule(message:String , start:NSDate , repeating : Int , completion : ((Bool)->())?){
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.locale = enUSPosixLocale
        Alamofire.request(.POST , Constants.urlSchedules ,
            parameters: ["message":message , "repeating":repeating , "datetime":formatter.stringFromDate(start)], headers:self.headers)
            .responseJSON{ response in
                completion!(true)
        }
    }
    
    static func updateAuthCode(serviceID : String , code : String , completion : ((Bool)->())?){
        
        Alamofire.request(.POST , Constants.urlAuthCode ,
            parameters: ["service_id":serviceID , "code" : code], headers:self.headers)
            .responseJSON{ response in
                completion!(true)
        }
    }
    
    static func signup(username:String,email:String , password:String , completion : ((Bool)->())?){
        Alamofire.request(.POST , Constants.urlSignup ,
            parameters: ["username":username , "email":email , "password":password])
            .validate()
            .response{ response in
                completion!(true)

        }
    }
    
}