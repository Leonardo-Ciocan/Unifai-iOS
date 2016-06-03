//
//  Cache.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 03/06/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation
import SwiftyJSON

extension NSFileManager {
    func fileSizeAtPath(path: String) -> Int64 {
        do {
            let fileAttributes = try attributesOfItemAtPath(path)
            let fileSizeNumber = fileAttributes[NSFileSize]
            let fileSize = fileSizeNumber?.longLongValue
            return fileSize!
        } catch {
            print("error reading filesize, NSFileManager extension fileSizeAtPath")
            return 0
        }
    }
    
    func folderSizeAtPath(path: String) -> Int64 {
        var size : Int64 = 0
        do {
            let files = try subpathsOfDirectoryAtPath(path)
            for (i,_) in files.enumerate() {
                size += fileSizeAtPath((path as NSString).stringByAppendingPathComponent(files[i]) as String)
            }
        } catch {
            print("error reading directory, NSFileManager extension folderSizeAtPath")
        }
        return size
    }
}

class Cache{
    
    static let documentsDirectoryPathString = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!)
    static let cacheFolder = documentsDirectoryPathString.URLByAppendingPathComponent("cache")
    
    

    
    static func saveJSON(name:String , data : JSON){
        do {
            if !NSFileManager.defaultManager().fileExistsAtPath(cacheFolder.path!){
                try NSFileManager.defaultManager().createDirectoryAtPath(cacheFolder.path!, withIntermediateDirectories: false, attributes: nil)
        }
            
            let filePath = cacheFolder.URLByAppendingPathComponent(name+".json")
            let jsonData = try data.rawData(options: .PrettyPrinted)
            
            if !NSFileManager.defaultManager().fileExistsAtPath(filePath.path!){
                NSFileManager.defaultManager().createFileAtPath(filePath.path!, contents: jsonData, attributes: nil)
            }
            else{
                let file = try NSFileHandle(forWritingToURL: filePath)
                file.writeData(jsonData)
            }
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
    
    
    static func getFeed(completion : ([Message])->()) {
        let feedPath = cacheFolder.URLByAppendingPathComponent("feed.json")
        if !NSFileManager.defaultManager().fileExistsAtPath(feedPath.path!) {
            completion([])
            return
        }
        do{
            let file = try NSFileHandle(forReadingFromURL: feedPath)
            let json_data =     JSON(data:file.readDataToEndOfFile())
            
            guard let json = json_data.array else {
                print("json not array")
                completion([])
                return
            }
            
            var messages : [Message] = []
            for message in json{
                messages.append(Message(json: message))
            }
            completion(messages)
        }
        catch let error as NSError {
            print("error occured getting cache")
            completion([])
        }
    }
    
    
    
    static func getDashboard(completion : ([Message])->()) {
        let feedPath = cacheFolder.URLByAppendingPathComponent("dashboard.json")
        if !NSFileManager.defaultManager().fileExistsAtPath(feedPath.path!) {
            completion([])
            return
        }
        do{
            let file = try NSFileHandle(forReadingFromURL: feedPath)
            let json_data =  JSON(data:file.readDataToEndOfFile())
            
            guard let json = json_data.array else {
                print("json not array")
                completion([])
                return
            }
            
            var messages : [Message] = []
            for message in json{
                messages.append(Message(json: message))
            }
            completion(messages)
        }
        catch let error as NSError {
            print("error occured getting cache")
            completion([])
        }
    }

    
}