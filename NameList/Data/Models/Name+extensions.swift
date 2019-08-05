//
//  Name+extensions.swift
//  NameList
//
//  Created by Paul Wood on 8/1/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation

extension Name: Identifiable {
  public var id: String {
    return name!
  }
}

extension Name: LoggingStringConvertable {
  public var loggingDescription: String {
    return "Name(\(name ?? "NaN"):\(self.objectID))"
  }
}
