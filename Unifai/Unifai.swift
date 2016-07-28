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
                    Core.Services = services
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
                    let json_data = JSON(data)
                    Cache.saveJSON("feed", data: json_data)
                    let json = json_data.array
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
                    let json_data = JSON(data)
                    print("writing dashboard.json")
                    Cache.saveJSON("dashboard", data: json_data)
                    
                    let json = json_data.array
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
    
    /// - parameters:
    ///     - String : The ID of the service
    ///     - (Message,[Message]) -> () : Returns the pinned message and a list of messages
    static func getProfile(serviceID : String , completion : (Message,[Message])->()) {
        
        Alamofire.request(.GET , Constants.urlServiceProfile + serviceID , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data)
                    
                    let pinnedMessage = Message(json: json["pinnedMessage"])
                    
                    let array = json["messages"].array
                    var messages : [Message] = []
                    for message in array!{
                        messages.append(Message(json: message))
                    }
                    completion(pinnedMessage,messages)
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
    
    
    static func updatePassportLocation(withLatitude latitude : String , longitude : String){
        Alamofire.request(.POST , Constants.urlPassportLocation ,
            parameters: ["latitude":latitude , "longitude" : longitude], headers:self.headers)
            .responseJSON{ response in
        }
    }
    
    
    static func runAction(action : Action , completion : ((Message)->())?){
        
        Alamofire.request(.POST , Constants.urlRunAction ,
            parameters: ["message" : action.message], headers:self.headers)
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data)
                    completion!(Message(json: json))
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
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
    
    static func sendMessage(content : String , imageData : NSData , completion : ((Bool)->())?){
        Alamofire.upload(.POST, Constants.urlMessage ,headers: self.headers, multipartFormData:{
                formData in
            formData.appendBodyPart(data: imageData, name: "file",fileName: "file.png",mimeType: "image/png")
                formData.appendBodyPart(data: content.dataUsingEncoding(NSUTF8StringEncoding)!, name: "content")
                formData.appendBodyPart(data: String(MessageType.ImageUpload.rawValue).dataUsingEncoding(NSUTF8StringEncoding)!, name: "type")
            }, encodingCompletion: { result in
                switch result {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        completion!(true)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    static func getDataForMessage(withID id:String, completion : ((NSData)->())) {
        Alamofire.request(.GET, Constants.urlFile + id, parameters: [:], headers: self.headers)
            .responseData(completionHandler: { result in
                completion(result.data!)
            })
    }
    
    static func deleteThread(thread:String , completion : ((Bool)->())?){
        Alamofire.request(.DELETE , Constants.urlThread + thread , headers:self.headers)
            .responseJSON{ response in
                guard completion != nil else{return}
                completion!(true)
        }
    }
    
    static func deleteAction(actionID:String , completion : ((Bool)->())?){
        Alamofire.request(.DELETE , Constants.urlAction + actionID, headers:self.headers)
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
    
    static func getCatalog( completion : ([String:[CatalogItem]])->() ) {
        Alamofire.request(.GET , Constants.urlCatalog, headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data).dictionaryValue
                    print(JSON(data))
                    var result : [String:[CatalogItem]] = [:]
                    for (service,examples) in json {
                        var items : [CatalogItem] = []
                        if let array = examples.array {
                            for item in array{
                                items.append(CatalogItem(json:item))
                            }
                        }
                        result[service] = items
                    }
                    completion(result)
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