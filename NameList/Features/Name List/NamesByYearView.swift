//
//  NamesByYearView.swift
//  NameList
//
//  Created by Paul Wood on 7/31/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import SwiftUI
import CoreData
import Combine

struct NamesByYearView: View {
  
  @EnvironmentObject var coreDataStack: CoreDataStack
  @Environment(\.managedObjectContext) var managedObjectContext
  @EnvironmentObject var importer: NameDatabaseImporter
  
  @ObservedObject var year: YearOfBirth
  var years: FetchRequest<CountForNameByYear>
  @Binding var ascending: Bool
  
  var body: some View {
    VStack {
      HStack {
        Text("Total Names: \(years.wrappedValue.count)")
        Text("Sort Order: \($ascending.wrappedValue ? "Ascending" : "Decending")")
      }
      
      List(years.wrappedValue) { count in
        HStack {
          VStack(alignment: .leading) {
            Text(count.name?.name ?? "" ).font(.headline)
            Text("\(count.name?.gender == "F" ? "👩" : "👨")").font(.caption)
          }
          Spacer()
          Text("\(count.count)")
        }
      }
    }
    .navigationBarItems(trailing: Button(action: {
      self.ascending.toggle()
    }, label: { Text("Toggle Sort") }))
      .navigationBarTitle(Text("Names from \(year.year ?? "")") )
      .onAppear {
        self.importer.startParsing(year: self.year)
    }
    
  }
}

struct FetchedResultWidget: View {
  
  @Environment(\.managedObjectContext) var managedObjectContext
  @ObservedObject var year: YearOfBirth
  var ascendingPublisher = CurrentValueSubject<Bool, Never>(true)
  
  private let view: SwiftUI.State<NamesByYearView>
  private let viewPublisher: AnyPublisher<NamesByYearView, Never>
  
  var ascending: Binding<Bool>
  
  public init(year: YearOfBirth) {
    self.year = year
    let request = CountForNameByYear.fetchRequest(forYear: year,
                                                  ascending: false)
    let fetchRequest = FetchRequest<CountForNameByYear>(fetchRequest: request)
    
    let ascendingPublisher = CurrentValueSubject<Bool, Never>(true)
    self.ascendingPublisher = ascendingPublisher
    let ascending = Binding(
      get: {
        ascendingPublisher.value
    },
      set: {
        ascendingPublisher.send($0)
    })
    self.ascending = ascending
    
    self.view = SwiftUI.State(initialValue:
      NamesByYearView(year: year, years: fetchRequest, ascending: ascending)
    )
    
    self.viewPublisher = ascendingPublisher.dropFirst()
      .map { value in
        let fetchRequest = FetchRequest<CountForNameByYear>(
          entity: CountForNameByYear.entity(),
          sortDescriptors: [NSSortDescriptor(key: "count", ascending: value)],
          predicate: NSPredicate(format: "%K = %@",
                                 Schema.CountForNameByYear.yearOfBirth.rawValue,
                                 year))
        return NamesByYearView(year: year,
                               years: fetchRequest,
                               ascending: ascending)
    }
    .eraseToAnyPublisher()
  }
  
  public var body: some View {
    return view.value.bind(viewPublisher, to: view.binding)
  }
}

//struct FetchedResultContainer: View {
//
//  @Environment(\.managedObjectContext) var managedObjectContext
//  @ObservedObject var year: YearOfBirth
//  var ascending: State<Bool>
//
//  init(year: YearOfBirth) {
//    self.year = year
//    self.ascending = State(initialValue: false)
//  }
//
//  var body: some View {
//    return NamesByYearView(year: self.year,
//                           years: self.years())
//  }
//
//  func years() -> FetchRequest<CountForNameByYear> {
//        let request = CountForNameByYear.fetchRequest(forYear: year,
//                                           ascending: ascending.value)
//    let fetchRequest = FetchRequest<CountForNameByYear>(fetchRequest: request)
//    return fetchRequest
//  }
//}




extension View {
  func bind<P: Publisher, Value>(
    _ publisher: P,
    to binding: Binding<Value>
  ) -> some View where P.Failure == Never, P.Output == Value {
    return onReceive(publisher) { value in
      binding.value = value
    }
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
