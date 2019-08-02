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
  
  @Published var displayNames: [Name] = []
  
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
               in context: NSManagedObjectContext,
               shouldSave: Bool = true,
               completionHandler: ((_ newName: Name) -> Void)? = nil) {
    context.perform {
      let name = Name(context: context)
      name.name = nameType.name
      name.gender = nameType.gender
      name.count = Int64(nameType.count)
      if shouldSave {
        context.save(with: .addName)
      }
      completionHandler?(name)
    }
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

extension NameDatabaseProvider: NSFetchedResultsControllerDelegate {
  
  public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                         didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
    if let newObjects = controller.fetchedObjects as? [Name] {
      self.displayNames = newObjects
    }
  }
}
