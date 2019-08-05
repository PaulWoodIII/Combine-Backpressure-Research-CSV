//
//  NameDatabaseImporter.swift
//  NameList
//
//  Created by Paul Wood on 8/1/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import Combine
import CoreData

class NameDatabaseImporter: ObservableObject {
  
  enum NameDatabaseImportError: Error {
    case databaseError
  }
  
  let provider: NameDatabaseProvider
  let yearProvider: YearDatabaseProvider
  var cancelParse: Cancellable?
  let syncContext: NSManagedObjectContext
  private var cache: [String: NSManagedObjectID] = [:]
  private let bgq: DispatchQueue = DispatchQueue.init(label: "FIFO Worker")
  
  init(provider: NameDatabaseProvider, yearProvider: YearDatabaseProvider) {
    self.provider = provider
    self.yearProvider = yearProvider
    self.syncContext = provider.persistentContainer.backgroundContext()
    cancelParse = createYears().makeConnectable().connect()
  }
  
  func createYears() -> AnyPublisher<NSManagedObject, Never> {
    return Publishers.Sequence<NameFile.AllCases, Never>(sequence: NameFile.allCases)
      .receive(on: bgq)
      .subscribe(on: bgq)
      .flatMap({ (file: NameFile) -> Future<NSManagedObject, Never> in
        let yearOfBirth = file.rawValue.replacingOccurrences(of: "yob", with: "")
        return Future { (promise) in
          self.yearProvider.addYear(yearOfBirth,
                                    in:self.syncContext,
                                    shouldSave: true) { (nameMO: YearOfBirth) in
                                      promise(.success(nameMO))
          }
        }
      })
      .eraseToAnyPublisher()
  }
  
  func createNames(year incYear: YearOfBirth) -> AnyPublisher<Name, NameDatabaseImportError> {
    let syncYear = syncContext.object(with: incYear.objectID) as! YearOfBirth
    guard let yearString = syncYear.year else {
      preconditionFailure("Year not initialized before parsing started")
    }
    let filename: String = "yob" + yearString
    guard let file = NameFile(rawValue: filename) else {
      return Fail<Name, NameDatabaseImportError>(error: .databaseError).eraseToAnyPublisher()
    }
    return NameImporter().importFrom(assetNamed: file.rawValue)
      .mapError { (error) -> NameDatabaseImportError in
        return .databaseError
    }
    .buffer(size: Int.max, prefetch: .byRequest, whenFull: .customError({return .databaseError}))
    .map({ incName -> Name in
      return self.provider.addName(
        name: incName,
        forYear: syncYear,
        in:self.syncContext,
        shouldSave: false)
    })
      .eraseToAnyPublisher()
  }
  
  func startParsing() {
    guard case .success(let years) = YearOfBirth.allYears(inContext: syncContext) else {
      preconditionFailure("Year not initialized before parsing started")
    }
    cancelParse = Publishers.Sequence(sequence: years)
      .receive(on: bgq)
      .subscribe(on: bgq)
      .setFailureType(to: NameDatabaseImportError.self)
      .flatMap({ (year) -> AnyPublisher<Name, NameDatabaseImportError> in
        return self.createNames(year: year)
      })
      .singleSink(receiveCompletion: { (error) in
        self.syncContext.save(with: .batchAddNames)
      }, receiveValue: { val in
        self.syncContext.save(with: .batchAddNames)
      })
  }
  
  func startParsing(year incYear: YearOfBirth) {
    let syncYear = self.syncContext.object(with: incYear.objectID) as! YearOfBirth
    cancelParse = self.createNames(year: syncYear)
      .subscribe(on: bgq)
      .receive(on: bgq)
      .collect(1000)
      .handleEvents(receiveOutput: { _ in
        self.syncContext.save(with: .batchAddNames)
      })
      .delay(for: 0.25, scheduler: DispatchQueue.main)
      .singleSink(receiveCompletion: { (complete: Subscribers.Completion<NameDatabaseImporter.NameDatabaseImportError>) in
        self.syncContext.save(with: .batchAddNames)
      }, receiveValue: { _ in
        self.syncContext.save(with: .batchAddNames)
      })
    
  }
}
