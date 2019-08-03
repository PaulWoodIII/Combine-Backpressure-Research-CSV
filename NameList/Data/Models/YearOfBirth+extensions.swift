//
//  YearOfBirth+extensions.swift
//  NameList
//
//  Created by Paul Wood on 8/2/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation

extension YearOfBirth: Identifiable {
  public var id: String {
    return year!
  }
}
