//
//  MessageCreatorDelegate.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 28/05/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation
import UIKit

protocol MessageCreatorDelegate : class {
    func shouldAppendMessage(_ message:Message)
    func didStartWriting()
    func didFinishWirting()
    func shouldThemeHostWithColor(_ color:UIColor)
    func shouldRemoveThemeFromHost()
}
