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
  var dataSource: UITableViewDiffableDataSource<Section, Name>?
  var currentSnapshot: NSDiffableDataSourceSnapshot<NameTableCoordinator.Section, Name>!
  enum Section: String, CaseIterable {
      case main
  }
  
  init(coreDataStack: CoreDataStack) {
    super.init()
    self.provider = NameDatabaseProvider(with: coreDataStack.persistentContainer,
                                         fetchedResultsControllerDelegate: self)
  }

  func setup(tableView: UITableView) {
    let ds = UITableViewDiffableDataSource<Section, Name>(tableView: tableView, cellProvider: { (tableView, indexPath, name: Name) -> UITableViewCell? in
      var cell = tableView.cellForRow(at: indexPath)
      if cell == nil {
        cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
      }
      cell?.textLabel?.text = name.name
      return cell
    })
    if let snapshot = self.currentSnapshot {
      ds.apply(snapshot)
    } else {
      let snapshot = NSDiffableDataSourceSnapshot<Section, Name>()
      snapshot.appendSections([Section.main])
      snapshot.appendItems([], toSection: .main)
      ds.apply(snapshot)
    }
    tableView.dataSource = ds
    self.dataSource = ds
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChangeContentWith ref: NSDiffableDataSourceSnapshotReference) {
    let snapshot = NSDiffableDataSourceSnapshot<NameTableCoordinator.Section, Name>()
    snapshot.appendSections([Section.main])
    if let name = ref.itemIdentifiers as? [Name] {
      snapshot.appendItems(name, toSection: .main)
    }
    currentSnapshot = snapshot
    dataSource?.apply(snapshot)
  }
  
//  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//      tableView?.reloadData()
//  }
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

