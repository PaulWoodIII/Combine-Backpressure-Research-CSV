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
  
  public init(_ name: String, _ gender: String, _ count: Int) {
    self.name = name
    self.gender = gender
    self.count = count
  }
}

extension NameType: Equatable {}

extension NameType: CustomStringConvertible {
  var description: String {
    return "\(name):\(gender):\(count)"
  }
}
