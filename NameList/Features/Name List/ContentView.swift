//
//  ContentView.swift
//  NameList
//
//  Created by Paul Wood on 7/31/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  
  @EnvironmentObject var coreDataStack: CoreDataStack
  @Environment(\.managedObjectContext) var managedObjectContext
  @ObservedObject var year: YearOfBirth
  @EnvironmentObject var importer: NameDatabaseImporter

  var body: some View {
    VStack {
      NamesByYearCollectionView(year: year, context: managedObjectContext)
    }
    .navigationBarTitle(Text("Names from \(year.year ?? "")") )
    .onAppear {
      self.importer.startParsing(year: self.year)
    }

  }
}

//#if DEBUG
//struct ContentView_Previews: PreviewProvider {
//  static var previews: some View {
//    ContentView().appEnvironment()
//  }
//}
//#endif
