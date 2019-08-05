//
//  YearOfBirth+extensions.swift
//  NameList
//
//  Created by Paul Wood on 8/2/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import CoreData

extension YearOfBirth: Identifiable {
  public var id: String {
    return year!
  }
}

extension YearOfBirth: LoggingStringConvertable {
  public var loggingDescription: String {
    return "YearOfBirth(\(year ?? "NaN"):\(self.objectID))"
  }
}

extension YearOfBirth {
  static func allFetchRequest() -> NSFetchRequest<YearOfBirth> {
    let request: NSFetchRequest<YearOfBirth> = YearOfBirth.fetchRequest() //YearOfBirth.fetchRequest() as! NSFetchRequest<YearOfBirth>
    request.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true)]
    return request
  }
  
  static func allYears(inContext context: NSManagedObjectContext) -> Result<[YearOfBirth], Error> {
    let request: NSFetchRequest<YearOfBirth> = YearOfBirth.fetchRequest() //YearOfBirth.fetchRequest() as! NSFetchRequest<YearOfBirth>
    request.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true)]
    var fetchedElements: [YearOfBirth]?
    var err: Error?
    context.performAndWait {
      do {
        fetchedElements = try context.fetch(request)
      } catch {
        err = error
      }
    }
    if let fetchedElements = fetchedElements  {
      return .success(fetchedElements)
    } else {
      if let err = err {
        return .failure(err)
      }
      return .failure(NSError())
    }
  }
  
}
