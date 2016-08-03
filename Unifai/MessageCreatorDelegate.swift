//
//  MessageCreatorDelegate.swift
//  Unifai
//
//  Created by Leonardo Ciocan on 28/05/2016.
//  Copyright © 2016 Unifai. All rights reserved.
//

import Foundation

protocol MessageCreatorDelegate : class {
    func shouldRefreshData()
    func didStartWriting()
    func didFinishWirting()
    func didSelectService(service:Service?)
}