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
  var ascending: Binding<Bool>

  init(year: YearOfBirth,
       years: FetchRequest<CountForNameByYear>,
       ascending: Binding<Bool>) {
    self.year = year
    self.years = years
    self.ascending = ascending
  }
  
  var body: some View {
    VStack {
      NamesByYearCollectionView(year: year, context: managedObjectContext)
    }
    .navigationBarItems(leading: Button(action: {
      self.ascending.wrappedValue.toggle()
    }, label: { Text("Toggle") }))
    .navigationBarItems(trailing: Text("Total Names: \(years.wrappedValue.count)"))
    .navigationBarTitle(Text("Names from \(year.year ?? "")") )
    .onAppear {
      self.importer.startParsing(year: self.year)
    }
    
  }
}

struct FetchedResultContainer: View {
  
  @Environment(\.managedObjectContext) var managedObjectContext
  @ObservedObject var year: YearOfBirth
  var years: FetchRequest<CountForNameByYear>
  var ascending: State<Bool>
  
  init(year: YearOfBirth, ascending: Bool = true) {
    self.year = year
    self.ascending = State(initialValue: true)
    let request = CountForNameByYear.fetchRequest(forYear: year, ascending: ascending)
    let fetchRequest = FetchRequest<CountForNameByYear>(fetchRequest: request)
    self.years = fetchRequest
  }
  
  var body: some View {
    return NamesByYearView(year: self.year,
                           years: self.years,
                           ascending: self.ascending.binding)
  }
}

//#if DEBUG
//struct ContentView_Previews: PreviewProvider {
//  @Environment(\.managedObjectContext) var managedObjectContext
//  static var previews: some View {
//
//    let year = YearOfBirth()
//    year.year = "1889"
//    return NamesByYearView(year: year, ascending: .constant(true)).appEnvironment()
//  }
//}
//#endif
