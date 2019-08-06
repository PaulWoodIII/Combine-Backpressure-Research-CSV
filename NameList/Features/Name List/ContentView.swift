//
//  NamesByYearView.swift
//  NameList
//
//  Created by Paul Wood on 7/31/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import SwiftUI
import CoreData
struct NamesByYearView: View {
  
  @EnvironmentObject var coreDataStack: CoreDataStack
  @Environment(\.managedObjectContext) var managedObjectContext
  @ObservedObject var year: YearOfBirth
  @EnvironmentObject var importer: NameDatabaseImporter
  var years: FetchRequest<CountForNameByYear>

  init(year: YearOfBirth) {
    self.year = year
    self.years = FetchRequest(fetchRequest: CountForNameByYear.fetchRequest(forYear: year))
  }
  
  var body: some View {
    VStack {
      NamesByYearCollectionView(year: year, context: managedObjectContext)
      }
    .navigationBarItems(trailing: Text("Total Names: \(years.wrappedValue.count)"))
    .navigationBarTitle(Text("Names from \(year.year ?? "")") )
    .onAppear {
      self.importer.startParsing(year: self.year)
    }

  }
}

//#if DEBUG
//struct ContentView_Previews: PreviewProvider {
//  static var previews: some View {
//    NamesByYearView().appEnvironment()
//  }
//}
//#endif
