//
//  WrappedTableView.swift
//  NameList
//
//  Created by Paul Wood on 8/1/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import SwiftUI
import CoreData

class NamesByYearCollectionViewCoordinator: NSObject, NSFetchedResultsControllerDelegate {
  var dataSource: UICollectionViewDiffableDataSource<Section, NSManagedObjectID>!
  var fetchedResultsController: NSFetchedResultsController<CountForNameByYear>!
  enum Section: String, CaseIterable {
    case main
  }
  init(context: NSManagedObjectContext,
       year: YearOfBirth) {
    super.init()
    let controller = CountForNameByYear.fetchController(forYear: year, inContext: context)
    controller.delegate = self
    self.fetchedResultsController = controller
  }
  func setup(collectionView: UICollectionView) {
    let ds = UICollectionViewDiffableDataSource<Section, NSManagedObjectID>(collectionView: collectionView) { (collectionView, indexPath, countID) -> UICollectionViewCell? in
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: NameCollectionViewCell.reuseIdentifier,
        for: indexPath) as! NameCollectionViewCell
      let moc = self.fetchedResultsController.managedObjectContext
      guard let count = try? moc.existingObject(with: countID) as? CountForNameByYear else {
          return cell
      }
      cell.nameLabel.text = count.name?.name ?? "NAN"
      cell.genderLabel.text = count.name?.gender == "F" ? "👧" : "👦"
      cell.countLabel.text = "\(count.count)"
      return cell
    }
    collectionView.dataSource = ds
    self.dataSource = ds
    try! self.fetchedResultsController.performFetch()
  }
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
    let snap = snapshot as NSDiffableDataSourceSnapshot<Section, NSManagedObjectID>
    dataSource.apply(snap, animatingDifferences: true)
  }
}

struct NamesByYearCollectionView: UIViewRepresentable {
  
  let year: YearOfBirth
  let context: NSManagedObjectContext

  typealias UIViewType = UICollectionView
  
  func makeUIView(context: UIViewRepresentableContext<NamesByYearCollectionView>) -> UICollectionView {
    let collectionViewLayout = createLayout()
    let view = UICollectionView(frame: UIScreen.screens.first?.bounds ?? CGRect.zero,
                                collectionViewLayout: collectionViewLayout)
    view.backgroundColor = UIColor.systemBackground
    let nib = UINib(nibName: "NameCollectionViewCell", bundle: Bundle.main)
    
    view.register(nib,
                  forCellWithReuseIdentifier: NameCollectionViewCell.reuseIdentifier)
    context.coordinator.setup(collectionView: view)
    return view
  }
  
  func updateUIView(_ uiView: UICollectionView,
                    context: UIViewRepresentableContext<NamesByYearCollectionView>) {
    //let the fetched results controller handle it
  }
  
  func makeCoordinator() -> NamesByYearCollectionViewCoordinator {
    let coordinator = NamesByYearCollectionViewCoordinator(context: context, year: year)
    return coordinator
  }
  
  private func createLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .estimated(44))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                   subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    return layout
  }
}

