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
    }.navigationBarItems(trailing:
      Button(
        action: {
          self.ascending.toggle()
      },
        label: { Text("Toggle Sort") }
    )).navigationBarTitle(Text("Names from \(year.year ?? "")") )
      .onAppear {
        self.importer.startParsing(year: self.year)
    }
    
  }
}

struct FetchedResultWidget: View {
  
  @Environment(\.managedObjectContext) var managedObjectContext
  @ObservedObject var year: YearOfBirth
  var ascendingPublisher: CurrentValueSubject<Bool, Never>
  var fetchRequestPublisher: PassthroughSubject<(NSFetchRequest<CountForNameByYear>, NSManagedObjectContext), Never>
  var debugPublisher: AnyPublisher<Void, Never>
  
  private let view: SwiftUI.State<NamesByYearView>
  private let viewPublisher: AnyPublisher<NamesByYearView, Never>
  
  var ascending: Binding<Bool>
  
  public init(year: YearOfBirth, context: NSManagedObjectContext) {
    
    self.year = year
    let fetchRequestPublisher = PassthroughSubject<(NSFetchRequest<CountForNameByYear>, NSManagedObjectContext), Never>()
    self.fetchRequestPublisher = fetchRequestPublisher
    let ascendingPublisher = CurrentValueSubject<Bool, Never>(false)
    self.ascendingPublisher = ascendingPublisher
    
    let ascending = Binding(
      get: {
        ascendingPublisher.value
    },
      set: {
        ascendingPublisher.send($0)
    })
    self.ascending = ascending
    
    func debugFetch(request: NSFetchRequest<CountForNameByYear>,
                    context: NSManagedObjectContext) {
      context.performAndWait {
        if let results = try? request.execute() {
          log.verbose(results)
        }
      }
    }
    
    func render(year: YearOfBirth, ascendingValue: Bool, context: NSManagedObjectContext) -> NamesByYearView {
      let request = CountForNameByYear.fetchRequest(forYear: year,
                                                    ascending: ascendingValue)
      let fetchRequest = FetchRequest<CountForNameByYear>(fetchRequest: request)
      fetchRequestPublisher.send((request, context))
      return NamesByYearView(year: year, years: fetchRequest, ascending: ascending)
    }
    
    self.view = SwiftUI.State(initialValue:
      render(year: year, ascendingValue: false, context: context)
    )
    
    self.viewPublisher = ascendingPublisher
      .dropFirst()
      .map { value in
        return render(year: year, ascendingValue: value, context: context)
    }.eraseToAnyPublisher()
    
    debugPublisher = fetchRequestPublisher.map({ (v, context) in
      debugFetch(request: v, context: context)
      print(v)
      }).eraseToAnyPublisher()
  }
  
  public var body: some View {
    return view.value.bind(viewPublisher, to: view.binding)
      .onReceive(debugPublisher) { _ in
      print("")
    }
  }
}

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
