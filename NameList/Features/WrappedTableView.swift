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
  var collectionView: UICollectionView?
  var provider: NameDatabaseProvider!
  var dataSource: UICollectionViewDiffableDataSourceReference?
  var currentSnapshot: UICollectionViewDiffableDataSourceReference!
  enum Section: String, CaseIterable {
    case main
  }
  
  init(coreDataStack: CoreDataStack) {
    super.init()
    self.provider = NameDatabaseProvider(with: coreDataStack.persistentContainer,
                                         fetchedResultsControllerDelegate: self)
    _ = try? self.provider.fetchedResultsController.performFetch()
  }
  
  func setup(collectionView: UICollectionView) {
    
    let ds = UICollectionViewDiffableDataSourceReference(collectionView: collectionView) { (collectionView, indexPath, someObject) -> UICollectionViewCell? in
      var cell = collectionView.dequeueReusableCell(withReuseIdentifier: NameCollectionViewCell.reuseIdentifier, for: indexPath) as! NameCollectionViewCell
      let moc = self.provider.persistentContainer.viewContext
      guard let moID = someObject as? NSManagedObjectID,
        let name = try? moc.existingObject(with: moID) as? Name else {
        return cell
      }
      cell.textLabel.text = name.name
      return cell
    }
        
    collectionView.dataSource = ds
    self.dataSource = ds
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChangeContentWith ref: NSDiffableDataSourceSnapshotReference) {
    dataSource?.applySnapshot(ref, animatingDifferences: true)
  }
}

struct WrappedTableView: UIViewRepresentable {
  
  let coreDataStack: CoreDataStack
  
  typealias UIViewType = UICollectionView
  
  func makeUIView(context: UIViewRepresentableContext<WrappedTableView>) -> UICollectionView {
    let collectionViewLayout = createLayout()
    let view = UICollectionView(frame: CGRect.zero,
                                collectionViewLayout: collectionViewLayout)
    view.backgroundColor = UIColor.systemBackground
    let nib = UINib(nibName: "NameCollectionViewCell", bundle: Bundle.main)
    
    view.register(nib,
                  forCellWithReuseIdentifier: NameCollectionViewCell.reuseIdentifier)
    context.coordinator.setup(collectionView: view)
    return view
  }
  
  func updateUIView(_ uiView: UICollectionView,
                    context: UIViewRepresentableContext<WrappedTableView>) {
    //let the fetched results controller handle it
  }
  
  func makeCoordinator() -> NameTableCoordinator {
    let coordinator = NameTableCoordinator(coreDataStack: coreDataStack)
    return coordinator
  }
  
  private func createLayout() -> UICollectionViewLayout {
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)

      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                            heightDimension: .absolute(44))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])

      let section = NSCollectionLayoutSection(group: group)

      let layout = UICollectionViewCompositionalLayout(section: section)
      return layout
  }
}

