//
//  CountForNameByYear+extensions.swift
//  NameList
//
//  Created by Paul Wood on 8/5/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import CoreData

extension CountForNameByYear: Identifiable {
  public var id: NSManagedObjectID {
    return self.objectID
  }
}

extension CountForNameByYear: LoggingStringConvertable {
  public var loggingDescription: String {
    return "CountForNameByYear(\(self.objectID):\(String(count)):Year(\(self.yearOfBirth?.year ?? "NaN"))"
  }
}

extension CountForNameByYear {
  
  static func all(forYear: YearOfBirth, inContext context: NSManagedObjectContext) -> Result<[CountForNameByYear], Error> {
    let request: NSFetchRequest<CountForNameByYear> = CountForNameByYear.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: true)]
    var fetchedElements: [CountForNameByYear]?
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
  
  static func fetchController(forYear: YearOfBirth, inContext context: NSManagedObjectContext) -> NSFetchedResultsController<CountForNameByYear> {
    let request: NSFetchRequest<CountForNameByYear> = CountForNameByYear.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false)]
    request.predicate = NSPredicate(format: "%K = %@", Schema.CountForNameByYear.yearOfBirth.rawValue, forYear)
    let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    return controller
  }
  
}
