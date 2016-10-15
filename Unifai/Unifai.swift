import Foundation
import Alamofire
import SwiftyJSON


enum ResponseStatus {
    case authenticationFailed
    case serverUnavailable
}

typealias ErrorHandler = ( () -> () )?

class Unifai{
    
    static var headers : Dictionary<String,String> {
        get{
            return ["Authorization":"Token " + UserDefaults.standard.string(forKey: "token")!]
        }
    }
    
    static func getThreads() -> [Message] {
        return []
    }
    
    static func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.string(forKey: "token") != nil
    }
        
    
    /**
        Logs in user
     
        - Returns: A token
    */
    static func login(_ username : String , password :String , completion : @escaping (String)->() , error : @escaping ()-> () ) {
        Alamofire.request(Constants.urlLogin , method: .post,
            parameters: ["username":username , "password":password])
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success:
                    let json = JSON(response.result.value!)
                    if let token = json["token"].string{
                        completion(token)
                    }
                case .failure:
                    error()
                }
              
        }
    }
    
    static func getServices(_ completion : @escaping ([Service]) -> ()){
        Alamofire.request( Constants.urlServices , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data).array
                    var services : [Service] = []
                    for service in json!{
                        services.append(Service(json: service))
                    }
                    Core.Services = services
                    completion(services)
                case .failure(let error):
                    print("getServices failed with error: \(error)")
                }
        }
    }
    
    static func getActions(_ completion : @escaping ([Action]) -> ()){
        Alamofire.request(Constants.urlAction , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data).array
                    var actions : [Action] = []
                    for action in json!{
                        actions.append(Action(json: action))
                    }
                    completion(actions)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    static func getThread(_ id:String , completion : @escaping ([Message])->()) {
        Alamofire.request( Constants.urlThread + id , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data).array
                    var messages : [Message] = []
                    for message in json!{
                        messages.append(Message(json: message))
                    }
                    completion(messages)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        
        }
    }
    
    static func getFeed(fromOffset offset: Int, andAmount amount: Int, completion : @escaping ([Message])->()) {
        Alamofire.request( Constants.urlFeed ,parameters: ["offset":offset, "limit":amount], headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json_data = JSON(data)
                    Cache.saveJSON("feed", data: json_data)
                    let json = json_data.array
                    var messages : [Message] = []
                    for message in json!{
                        messages.append(Message(json: message))
                    }
                    completion(messages)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    
    static func getDashboard(_ completion : @escaping ([Message])->()) {
        
        Alamofire.request(Constants.urlDashboard , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json_data = JSON(data)
                    print("writing dashboard.json")
                    Cache.saveJSON("dashboard", data: json_data)
                    
                    let json = json_data.array
                    print(json)
                    var messages : [Message] = []
                    for message in json!{
                        messages.append(Message(json: message))
                    }
                    completion(messages)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    /// - parameters:
    ///     - String : The ID of the service
    ///     - ([Message],[Message]) -> () : Returns the homepage messages and a list of recent messages from the feed
    static func getProfile(_ serviceID : String , completion : @escaping ([Message],[Message])->()) {
        
        Alamofire.request( Constants.urlServiceProfile + serviceID , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    
                    let array = json["messages"].array
                    var messages : [Message] = []
                    for message in array!{
                        messages.append(Message(json: message))
                    }
                    
                    let homepageArray = json["homepage"].array
                    var homepage : [Message] = []
                    homepage.append(contentsOf: homepageArray!.map{Message(json:$0)})
                    completion(homepage,messages)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    static func getUserProfile(_ completion : @escaping ([Message])->()) {
        
        Alamofire.request(Constants.urlUserProfile , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data).array
                    var messages : [Message] = []
                    for message in json!{
                        messages.append(Message(json: message))
                    }
                    completion(messages)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    static func getDashboardItems(_ completion : @escaping ([String])->()) {
        
        Alamofire.request( Constants.urlDashboardItems , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data).array
                    var messages : [String] = []
                    for message in json!{
                        if let x = message.string{
                            messages.append(x)
                        }
                    }
                    completion(messages)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    static func getGeniusSuggestionForThreadWithID(_ id :String, completion : @escaping ([GeniusGroup])->()) {
        
        Alamofire.request( Constants.urlGenius ,parameters: ["thread_id":id] , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    if let json = JSON(data).array {
                        completion(json.map({ GeniusGroup.fromJSON($0)! }))
                    }
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    static func setDashboardItems(_ items : [String], completion : ((Bool)->())?){
        Alamofire.request(Constants.urlDashboardItems , method: .post,
                          parameters: ["queries": items], headers:self.headers)
            .responseJSON{ response in
                completion!(true)
        }
    }
    
    
    static func sendMessage(_ content : String , completion : ((Message)->())? , error : @escaping () -> ()){
        Alamofire.request( Constants.urlMessage , method: .post,
            parameters: ["content":content], headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    completion!(Message(json: json))
                case .failure:
                    error()
                }
        }
    }
    
    
    static func updatePassportLocation(withLatitude latitude : String , longitude : String){
        Alamofire.request(Constants.urlPassportLocation , method: .post,
            parameters: ["latitude":latitude , "longitude" : longitude], headers:self.headers)
            .responseJSON{ response in
        }
    }
    
    
    static func runAction(_ action : Action , completion : ((Message)->())?){
        
        Alamofire.request( Constants.urlRunAction , method: .post,
            parameters: ["message" : action.message], headers:self.headers)
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    completion!(Message(json: json))
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    static func createAction(_ message : String ,name:String, completion : (()->())? , error : (()->())?){
        Alamofire.request(Constants.urlAction , method: .post,
            parameters: ["message":message,"name":name], headers:self.headers)
            .validate().response(completionHandler: { response in
                if response.error == nil {
                    completion!()
                }
                else {
                    let json = JSON(data: response.data!)
                    var dictionary = Dictionary<String,String>()
                    for (key, value) in json {
                        dictionary[key] = value.arrayValue[0].stringValue
                    }
                    error!()
                }
            })
    }
    
    static func sendMessage(_ content : String , thread : String , completion : ((Message)->())?){
        Alamofire.request( Constants.urlMessage , method: .post,
            parameters: ["content":content , "thread_id" : thread], headers:self.headers)
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    completion!(Message(json: json))
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    static func sendMessage(_ content : String , imageData : Data , completion : ((Message)->())?){
        Alamofire.upload(multipartFormData: {
            formData in
            formData.append( imageData, withName: "file",fileName: "file.png",mimeType: "image/png")
            formData.append( content.data(using: String.Encoding.utf8)!, withName: "content")
            formData.append( String(MessageType.imageUpload.rawValue).data(using: String.Encoding.utf8)!, withName: "type")
            }, to: Constants.urlMessage, encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        let json = JSON(response.result.value!)
                        completion!(Message(json: json))
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    static func getDataForMessage(withID id:String, completion : @escaping ((Data)->())) {
        Alamofire.request(Constants.urlFile + id, parameters: [:], headers: self.headers)
            .responseData(completionHandler: { result in
                completion(result.data!)
            })
    }
    
    static func deleteThread(_ thread:String , completion : ((Bool)->())?){
        Alamofire.request(Constants.urlThread + thread , method: .delete, headers:self.headers)
            .responseJSON{ response in
                guard completion != nil else{return}
                completion!(true)
        }
    }
    
    static func deleteAction(_ actionID:String , completion : ((Bool)->())?){
        Alamofire.request(Constants.urlAction + actionID, method: .delete ,headers:self.headers)
            .responseJSON{ response in
                guard completion != nil else{return}
                completion!(true)
        }
    }
    
    
    static func getUserInfo(_ completion : @escaping (_ username:String,_ email:String)->(), error : @escaping (ResponseStatus) -> ()) {
        Alamofire.request(Constants.urlUserInfo , headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    
                    completion(json["username"].stringValue , json["email"].stringValue)
                case .failure(let err):
                    error(.serverUnavailable)
                }
        }
    }
    
    static func getSchedules( _ completion : @escaping ([Schedule])->()) {
        
        Alamofire.request(Constants.urlSchedules, headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data).array
                    var schedules : [Schedule] = []
                    for schedule in json!{
                        schedules.append(Schedule(json: schedule))
                    }
                    completion(schedules)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    
                }
        }
    }
    
    static func getCatalog( _ completion : @escaping ([String:[CatalogItem]])->() ) {
        Alamofire.request(Constants.urlCatalog, headers:self.headers)
            .validate()
            .responseJSON{ response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data).dictionaryValue
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
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    
                }
        }
    }
    
    static func createSchedule(_ message:String , start:Date , repeating : Int , completion : ((Bool)->())?){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        formatter.locale = enUSPosixLocale
        Alamofire.request( Constants.urlSchedules , method:.post,
            parameters: ["message":message , "repeating":repeating , "datetime":formatter.string(from: start)], headers:self.headers)
            .responseJSON{ response in
                completion!(true)
        }
    }
    
    static func updateAuthCode(_ serviceID : String , code : String , completion : ((Bool)->())?){
        
        Alamofire.request(Constants.urlAuthCode , method:.post,
            parameters: ["service_id":serviceID , "code" : code], headers:self.headers)
            .responseJSON{ response in
                completion!(true)
        }
    }
    
    static func signup(_ username:String,email:String , password:String , completion : @escaping ()->() , error : @escaping (Dictionary<String,String>) -> ()) {
        Alamofire.request(Constants.urlSignup , method:.post,
            parameters: ["username":username , "email":email , "password":password])
            .validate().response(completionHandler: { response in
                if response.error == nil {
                    completion()
                }
                else {
                    let json = JSON(data: response.data!)
                    var dictionary = Dictionary<String,String>()
                    for (key, value) in json {
                        dictionary[key] = value.arrayValue[0].stringValue
                    }
                    error(dictionary)
                }
            })
            
        
        
    }
    
    static func isUserLoggedInToService(_ serviceName:String , completion : ((Bool)->())?){
        Alamofire.request( Constants.urlAuthStatus ,parameters: ["service_name":serviceName] , headers:self.headers)
            .responseString(completionHandler: { response in
                guard completion != nil else{return}
                print(response.result.value)
                completion!(response.result.value == "True")
        })
    }
    
    static func logoutFromService(_ serviceName:String){
        Alamofire.request( Constants.urlLogoutService, method:.post ,parameters: ["service_name":serviceName] , headers:self.headers)
    }
    
}
