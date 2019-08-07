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
  
  @Environment(\.managedObjectContext) var managedObjectContext
  @FetchRequest(fetchRequest: YearOfBirth.allFetchRequest()) var years: FetchedResults<YearOfBirth>
  @EnvironmentObject var importer: NameDatabaseImporter
  
  var body: some View {
    NavigationView{
      VStack {
        Text("Provided by Data.gov and Social Security records").font(.subheadline).lineLimit(nil)
        List(years) { (year: YearOfBirth) in
          NavigationLink(destination: FetchedResultWidget(year: year, context: self.managedObjectContext)) {
            Text(year.year ?? "NaN")
          }
        }
      }
      .navigationBarTitle("American Names")
      .navigationBarItems(trailing: Button(
        action: importer.startParsing,
        label: { Text("Parse") }
      ))
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
