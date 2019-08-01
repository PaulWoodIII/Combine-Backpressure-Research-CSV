//
//  NameDatabaseImporter.swift
//  NameList
//
//  Created by Paul Wood on 8/1/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import Combine

class NameDatabaseImporter: ObservableObject {
  
  let provider: NameDatabaseProvider
  var cancelParse: Cancellable?
  
  private let bgq: DispatchQueue = DispatchQueue.init(label: "FIFO Worker")
  
  init(provider: NameDatabaseProvider) {
    self.provider = provider
    startParsing()
  }
  
  func startParsing() {
    cancelParse = NameImporter().importFrom(file: .yob2000)
      .receive(on: bgq)
      .flatMap({ (incName: NameType) in
        return Future { (promise) in
          self.provider.addName(name: incName,
                           in: self.provider.persistentContainer.viewContext,
                           shouldSave: false) { (nameMO) in
            promise(.success(nameMO))
          }
        }
      }).sink(receiveCompletion: { (error) in
        self.provider.persistentContainer.viewContext.save(with: .batchAddNames)
      }, receiveValue: { val in
        print(val)
      })
  }
}
