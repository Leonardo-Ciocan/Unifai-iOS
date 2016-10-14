//
//  Cache.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 03/06/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation
import SwiftyJSON

extension FileManager {
    func fileSizeAtPath(_ path: String) -> Int64 {
        do {
            let fileAttributes = try attributesOfItem(atPath: path)
            let fileSizeNumber = fileAttributes[FileAttributeKey.size]
            let fileSize = (fileSizeNumber as AnyObject).int64Value
            return fileSize!
        } catch {
            print("error reading filesize, NSFileManager extension fileSizeAtPath")
            return 0
        }
    }
    
    func folderSizeAtPath(_ path: String) -> Int64 {
        var size : Int64 = 0
        do {
            let files = try subpathsOfDirectory(atPath: path)
            for (i,_) in files.enumerated() {
                size += fileSizeAtPath((path as NSString).appendingPathComponent(files[i]) as String)
            }
        } catch {
            print("error reading directory, NSFileManager extension folderSizeAtPath")
        }
        return size
    }
}

class Cache{
    
    static let documentsDirectoryPathString = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
    static let cacheFolder = documentsDirectoryPathString.appendingPathComponent("cache")
    
    

    
    static func saveJSON(_ name:String , data : JSON){
        do {
            if !FileManager.default.fileExists(atPath: cacheFolder.path){
                try FileManager.default.createDirectory(atPath: cacheFolder.path, withIntermediateDirectories: false, attributes: nil)
        }
            
            let filePath = cacheFolder.appendingPathComponent(name+".json")
            let jsonData = try data.rawData(options: .prettyPrinted)
            
            if !FileManager.default.fileExists(atPath: filePath.path){
                FileManager.default.createFile(atPath: filePath.path, contents: jsonData, attributes: nil)
            }
            else{
                let file = try FileHandle(forWritingTo: filePath)
                file.write(jsonData)
            }
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
    
    
    static func getFeed(_ completion : ([Message])->()) {
        let feedPath = cacheFolder.appendingPathComponent("feed.json")
        if !FileManager.default.fileExists(atPath: feedPath.path) {
            completion([])
            return
        }
        do{
            let file = try FileHandle(forReadingFrom: feedPath)
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
        catch _ as NSError {
            print("error occured getting cache")
            completion([])
        }
    }
    
    
    
    static func getDashboard(_ completion : ([Message])->()) {
        let feedPath = cacheFolder.appendingPathComponent("dashboard.json")
        if !FileManager.default.fileExists(atPath: feedPath.path) {
            completion([])
            return
        }
        do{
            let file = try FileHandle(forReadingFrom: feedPath)
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
        catch _ as NSError {
            print("error occured getting cache")
            completion([])
        }
    }

    
}
