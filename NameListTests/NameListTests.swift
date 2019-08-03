//
//  NameListTests.swift
//  NameListTests
//
//  Created by Paul Wood on 7/31/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import XCTest
@testable import NameList
import Combine

class NameListTests: XCTestCase {
  
  func testAssetsExist() {
    let sut = NameImporter()
    for f in NameFile.allCases {
      // The test is simple assert that something comes out for each file
      _ = sut.importFrom(assetNamed: f.rawValue).first().assertNoFailure().makeConnectable().connect()
    }
  }
  
  func testExample() {
    let sut = NameImporter()
    var names: [NameType]!
    _ = sut.importFrom(assetNamed: "test")
      .collect()
      .sink(receiveCompletion: { completion in
        
      }) { allNames in
        names = allNames
    }
    XCTAssertEqual(names, Fixtures.testNames)
  }
  
  func testBackpressure() {
    let sut = NameImporter()
    var names: [NameType] = []
    _ = sut.importFrom(assetNamed: "test")
      .slowSink(slowBy: 1,
                receiveCompletion: { completion in
      }) { nextName in
        // collect one by one to test
        names.append( nextName)
    }
    XCTAssertEqual(names, Fixtures.testNames)
  }
  
  func testSpeed() {
    self.measure {
      let sut = NameImporter()
      _ = sut.importFrom(assetNamed: "test").assertNoFailure().makeConnectable().connect()
    }
  }
  
}
