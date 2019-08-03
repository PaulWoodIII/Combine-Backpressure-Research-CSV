//
//  Schema.swift
//  NameList
//
//  Created by Paul Wood on 8/1/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import CoreData

/**
 Relevant entities and attributes in the Core Data schema.
 */
enum Schema {
  enum Name: String {
    case identifier, name, gender, countForYear
  }
  enum YearOfBirth: String {
    case year, countForNameByYear
  }
  enum CountForNameByYear: String {
    case count, name, yearOfBirth
  }
}

