//
//  WrappedTableView.swift
//  NameList
//
//  Created by Paul Wood on 8/1/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import SwiftUI
import CoreData

class NameTableCoordinator: NSObject, NSFetchedResultsControllerDelegate {
  var tableView: UITableView?
  var provider: NameDatabaseProvider!
  var dataSource: UITableViewDiffableDataSourceReference?
  var currentSnapshot: UITableViewDiffableDataSourceReference!
  enum Section: String, CaseIterable {
    case main
  }
  
  init(coreDataStack: CoreDataStack) {
    super.init()
    self.provider = NameDatabaseProvider(with: coreDataStack.persistentContainer,
                                         fetchedResultsControllerDelegate: self)
    _ = try? self.provider.fetchedResultsController.performFetch()
  }
  
  func setup(tableView: UITableView) {
    
    let ds = UITableViewDiffableDataSourceReference(tableView: tableView) { (tableView, indexPath, someObject) -> UITableViewCell? in
      var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
      if cell == nil {
        cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
      }
      let moc = self.provider.persistentContainer.viewContext
      guard let moID = someObject as? NSManagedObjectID,
        let name = try? moc.existingObject(with: moID) as? Name else {
        return cell
      }
      cell?.textLabel?.text = name.name
      return cell
    }
        
    tableView.dataSource = ds
    self.dataSource = ds
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChangeContentWith ref: NSDiffableDataSourceSnapshotReference) {
    dataSource?.applySnapshot(ref, animatingDifferences: true)
  }
}

struct WrappedTableView: UIViewRepresentable {
  
  let coreDataStack: CoreDataStack
  
  typealias UIViewType = UITableView
  
  func makeUIView(context: UIViewRepresentableContext<WrappedTableView>) -> UITableView {
    let view = UITableView()
    context.coordinator.setup(tableView: view)
    return view
  }
  
  func updateUIView(_ uiView: UITableView,
                    context: UIViewRepresentableContext<WrappedTableView>) {
    //let the fetched results controller handle it
  }
  
  func makeCoordinator() -> NameTableCoordinator {
    let coordinator = NameTableCoordinator(coreDataStack: coreDataStack)
    return coordinator
  }
}

