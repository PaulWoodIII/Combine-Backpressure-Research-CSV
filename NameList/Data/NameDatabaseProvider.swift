//
//  NameDatabaseProvider.swift
//  NameList
//
//  Created by Paul Wood on 8/1/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import CoreData

class NameDatabaseProvider: NSObject, ObservableObject {
    
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
  lazy var fetchedResultsController: NSFetchedResultsController<Name> = {
    let fetchRequest: NSFetchRequest<Name> = Name.fetchRequest()
    fetchRequest.sortDescriptors = [
      NSSortDescriptor(key: Schema.Name.gender.rawValue, ascending: true),
      NSSortDescriptor(key: Schema.Name.name.rawValue, ascending: true)
    ]
    
    let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                managedObjectContext: persistentContainer.viewContext,
                                                sectionNameKeyPath: Schema.Name.gender.rawValue,
                                                cacheName: nil)
    controller.delegate = fetchedResultsControllerDelegate
    
    do {
      try controller.performFetch()
    } catch {
      fatalError("###\(#function): Failed to performFetch: \(error)")
    }
    
    return controller
  }()
    
  func addName(name nameType: NameType,
               forYear: YearOfBirth,
               in context: NSManagedObjectContext,
               shouldSave: Bool = true) -> Name {
    log.verbose("ADD:\(nameType.loggingDescription)")
    var name: Name?
    context.performAndWait {
      let requestByIdentifier: NSFetchRequest<Name> = Name.fetchRequest()
      requestByIdentifier.predicate = NSPredicate(format: "%K = %@",
                                                  Schema.Name.identifier.rawValue,
                                                  nameType.identifiable)
      
      if let foundName = try? requestByIdentifier.execute().first {
        name = foundName
      } else {
        name = Name(context: context)
        name!.name = nameType.name
        name!.gender = nameType.gender
        name!.identifier = nameType.identifiable
      }
      
      if let _ = name!.countForYear?.allObjects.filter({ c in
        let count = c as! CountForNameByYear
        return count.name == name && count.yearOfBirth == forYear
      }).first {
        // Do nothing
      } else {
        let yearCount = CountForNameByYear(context: context)
        yearCount.count = Int64(nameType.count)
        yearCount.yearOfBirth = forYear
        yearCount.name = name
        
        forYear.addToCountForNameByYear(yearCount)
        name!.addToCountForYear(yearCount)
      }
      
      if shouldSave {
        context.save(with: .addName)
      }
    }
    return name!
  }
  
  func delete(name: Name,
              shouldSave: Bool = true,
              completionHandler: (() -> Void)? = nil) {
    guard let context = name.managedObjectContext else {
      fatalError("###\(#function): Failed to retrieve the context from: \(name)")
    }
    context.perform {
      context.delete(name)
      
      if shouldSave {
        context.save(with: .deleteName)
      }
      completionHandler?()
    }
  }
}
