//
//  YearList.swift
//  NameList
//
//  Created by Paul Wood on 8/2/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import SwiftUI
import CoreData
import Combine

struct YearList: View {
  
  @EnvironmentObject var coreDataStack: CoreDataStack
  @EnvironmentObject var yearProvider: YearFetcher
  
  var body: some View {
    NavigationView{
      VStack {
        Text("Provided by Data.gov and Social Security records").font(.subheadline).lineLimit(nil)
        List(yearProvider.displayData) { (year: YearOfBirth) in
          Text(year.year!)
        }
      }
    }
  }
}

#if DEBUG
struct YearList_Previews: PreviewProvider {
  static var previews: some View {
    YearList().appEnvironment()
  }
}
#endif

class YearFetcher: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
  var coreDataStack: CoreDataStack
  var yearDatabaseProvider: YearDatabaseProvider!
  
  var objectWillChange = PassthroughSubject<Void, Never>()
  
  @Published var displayData: [YearOfBirth] = []
  var currentObjectIds: [NSManagedObjectID] = []
  
  init(coreDataStack: CoreDataStack){
    self.coreDataStack = coreDataStack
    super.init()
    self.yearDatabaseProvider = YearDatabaseProvider(with: coreDataStack.persistentContainer,
                                                     fetchedResultsControllerDelegate: self)
    _ = self.yearDatabaseProvider.fetchedResultsController
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
    objectWillChange.send()
    currentObjectIds = currentObjectIds.applying(diff) ?? []
    self.displayData = currentObjectIds.compactMap { (id) -> YearOfBirth in
      return coreDataStack.persistentContainer.viewContext.object(with: id) as! YearOfBirth
    }
  }
  
}
