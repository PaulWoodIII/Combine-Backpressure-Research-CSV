//
//  YearDatabaseProvider.swift
//  NameList
//
//  Created by Paul Wood on 8/2/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import CoreData
import Combine

class YearDatabaseProvider: NSObject, ObservableObject {
    
  private(set) var persistentContainer: NSPersistentContainer
  private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
  
  init(with persistentContainer: NSPersistentContainer,
       fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?) {
    self.persistentContainer = persistentContainer
    self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
  }
  
  /**
   A fetched results controller for the Post entity, sorted by title.
   */
  lazy var fetchedResultsController: NSFetchedResultsController<YearOfBirth> = {
    let fetchRequest: NSFetchRequest<YearOfBirth> = YearOfBirth.fetchRequest()
    fetchRequest.sortDescriptors = [
      NSSortDescriptor(key: Schema.YearOfBirth.year.rawValue, ascending: true),
    ]
    
    let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                managedObjectContext: persistentContainer.viewContext,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)
    controller.delegate = fetchedResultsControllerDelegate
    
    do {
      try controller.performFetch()
    } catch {
      fatalError("###\(#function): Failed to performFetch: \(error)")
    }
    
    return controller
  }()
  
  func addYear(_ year: String,
               in context: NSManagedObjectContext,
               shouldSave: Bool = true,
               completionHandler: ((_ newName: YearOfBirth) -> Void)? = nil) {
    context.perform {
      let yearOfBirth = YearOfBirth(context: context)
      yearOfBirth.year = year
      if shouldSave {
        context.save(with: .addYear)
      }
      completionHandler?(yearOfBirth)
    }
  }
  
  func deleteYear(_ year: YearOfBirth,
              shouldSave: Bool = true,
              completionHandler: (() -> Void)? = nil) {
    guard let context = year.managedObjectContext else {
      fatalError("###\(#function): Failed to retrieve the context from: \(year)")
    }
    context.perform {
      context.delete(year)
      
      if shouldSave {
        context.save(with: .deleteYear)
      }
      completionHandler?()
    }
  }
  
}

