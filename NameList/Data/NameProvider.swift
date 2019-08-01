//
//  NameProvider.swift
//  NameList
//
//  Created by Paul Wood on 8/1/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import Combine

class NameProvider: ObservableObject {
  @Published var displayNames: [NameType] = []
  
  var cancelParseAndSort: Cancellable?
  
  private let bgq: DispatchQueue
  
  init() {
    let bgq = DispatchQueue.init(label: "FIFO Worker")
    self.bgq = bgq
    startParsing()
  }
  
  func startParsing() {
    cancelParseAndSort = NameImporter().importFrom(file: .yob2000)
    
      .receive(on: bgq)
      // keep the data set size manageable
      .filter({ return $0.count > 1000 })
      // minor premature optimization sort 50 at a time
      .collect(50)
      .scan([NameType](), { (all, new) -> [NameType] in
        return all + new
      })
      .map({ (items: [NameType]) in
        return items.sorted { (left, right) -> Bool in
          return left.count > right.count
        }
      })
      .replaceError(with: [NameType]())
      .delay(for: 1, scheduler: bgq)
      .receive(on: DispatchQueue.main)
      .assign(to: \.displayNames, on: self)
  }
}
