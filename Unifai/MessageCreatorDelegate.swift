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
    func shouldRefreshData()
    func didStartWriting()
    func didFinishWirting()
    func shouldThemeHostWithColor(color:UIColor)
    func shouldRemoveThemeFromHost()
}