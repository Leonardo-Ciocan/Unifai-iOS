//
//  Utils.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 27/04/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation

func matchesForRegexInText(regex: String!, text: String!) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = text as NSString
        let results = regex.matchesInString(text,
                                            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substringWithRange($0.range)}
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}