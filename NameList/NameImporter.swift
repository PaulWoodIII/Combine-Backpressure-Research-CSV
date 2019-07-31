//
//  NameImporter.swift
//  NameList
//
//  Created by Paul Wood on 7/31/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import CSV
import UIKit
import Combine

class NameImporter {
  
  enum NameImportError: Error {
    case csvError(_: CSVError)
    case bufferOverflow
  }
  
  func importFrom(file: NameFile) -> AnyPublisher<NameType, NameImportError> {
    guard let asset = NSDataAsset(name: file.rawValue) else {
      return Empty().eraseToAnyPublisher()
    }
    return importFrom(data: asset.data)
  }
  
  let passThrough = PassthroughSubject<NameType,NameImportError>()
  
  private func importFrom(data: Data) -> AnyPublisher<NameType, NameImportError> {
    
    do {
      let stream = InputStream(data: data)
      let reader = try CSVReader(stream: stream,
                                 hasHeaderRow: true)
      return Publishers.Sequence(sequence: reader)
        .buffer(size: 1, //Play with this value some
                prefetch: .keepFull, // you can play with this as well
                whenFull: Publishers.BufferingStrategy.customError{return .bufferOverflow})
        .map { row -> NameType in
          let name = NameType(row[0], row[1], Int(row[2])!)
          return name
        }.eraseToAnyPublisher()
    } catch {
      return Fail(error: .csvError(error as! CSVError)).eraseToAnyPublisher()
    }
  }
}

enum NameFile: String, CaseIterable {
  
  var type: String { "txt" }
  
  case test
  //TODO: Add More cases
}
