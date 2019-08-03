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
    startParsing()
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
  
  func saveName(year: YearOfBirth, name incName: NameType) -> AnyPublisher<Name, Never> {
    return Future<Name, Never> { promise in
      if let nameID = self.cache[incName.identifiable],
        let name = self.syncContext.object(with: nameID) as? Name {
        self.provider.addCountForNameByYear(
          name: name,
          nameType: incName,
          forYear: year,
          in: self.syncContext,
          shouldSave: true){ (nameMO) in
            promise(.success(nameMO))
        }
      } else {
        self.provider.addName(
          name: incName,
          forYear: year,
          in:self.syncContext,
          shouldSave: true) { (nameMO) in
            self.cache[nameMO.identifier!] = nameMO.objectID
            promise(.success(nameMO))
        }
      }
    }
    .eraseToAnyPublisher()
  }
  
  func createNames(year: YearOfBirth) -> AnyPublisher<Name, NameDatabaseImportError> {
    return Publishers.Sequence<NameFile.AllCases, NameDatabaseImportError>(sequence: NameFile.allCases)
      .flatMap ({ nameFile in
        return NameImporter().importFrom(assetNamed: nameFile.rawValue)
          .mapError { (error) -> NameDatabaseImportError in
            return .databaseError
        }
        .eraseToAnyPublisher()
      })
      .receive(on: bgq)
      .subscribe(on: bgq)
      .flatMap({ incName in
        return self.saveName(year: year, name: incName)
          .setFailureType(to: NameDatabaseImportError.self)
      })
      .receive(on: bgq)
      .subscribe(on: bgq)
      .eraseToAnyPublisher()
  }
  
  func startParsing() {
    cancelParse = self.createYears()
      .receive(on: bgq)
      .subscribe(on: bgq)
      .setFailureType(to: NameDatabaseImportError.self)
      .flatMap({ (year) -> AnyPublisher<Name, NameDatabaseImportError> in
        let yearOfBirth = year as! YearOfBirth
        return self.createNames(year: yearOfBirth)
      })
      .sink(receiveCompletion: { (error) in
        self.syncContext.save(with: .batchAddNames)
      }, receiveValue: { val in
        self.syncContext.save(with: .batchAddNames)
      })
  }
}
