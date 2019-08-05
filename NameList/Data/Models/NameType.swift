//
//  NameType.swift
//  NameList
//
//  Created by Paul Wood on 7/31/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation

struct NameType {
  var name: String
  var gender: String
  var count: Int
  
  var identifiable: String {
    return name+":"+gender
  }
  
  public init(_ name: String, _ gender: String, _ count: Int) {
    self.name = name
    self.gender = gender
    self.count = count
  }
}

extension NameType: Identifiable {
  var id: String {
    return identifiable
  }
}

extension NameType: Equatable, Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(gender)
    hasher.combine(count)
  }
}

extension NameType: CustomStringConvertible {
  var description: String {
    return "\(name):\(gender):\(count)"
  }
}

extension NameType: LoggingStringConvertable {
  public var loggingDescription: String {
    return "NameType(\(name):\(gender):\(count))"
  }
}

