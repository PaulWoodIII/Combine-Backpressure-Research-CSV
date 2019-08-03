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

public class NameImporter {
  
  public enum NameImportError: Error {
    case csvError(_: CSVError)
    case bufferOverflow
  }
  
  func importFrom(assetNamed: String) -> AnyPublisher<NameType, NameImportError> {
    guard let asset = NSDataAsset(name: assetNamed) else {
      return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
    return importFrom(data: asset.data)
  }
  
  let passThrough = PassthroughSubject<NameType,NameImportError>()
  
  private func importFrom(data: Data) -> AnyPublisher<NameType, NameImportError> {
    
    do {
      let stream = InputStream(data: data)
      let reader = try CSVReader(stream: stream,
                                 hasHeaderRow: true)
      // Sequence and Iterable helps us create a reactive state machine to Demand. Each requested element triggers a state transition and computation of the next returned value.
      return Publishers
        .Sequence(sequence: reader)
        .map { row -> NameType in
          let name = NameType(row[0], row[1], Int(row[2])!)
          return name
        }
        .eraseToAnyPublisher()
    } catch {
      return Fail(error: .csvError(error as! CSVError)).eraseToAnyPublisher()
    }
  }
}
