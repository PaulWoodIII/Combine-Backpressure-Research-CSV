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
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testExample() {
    let sut = NameImporter()
    var names: [NameType]!
    _ = sut.importFrom(file: NameFile.test)
      .collect()
      .sink(receiveCompletion: { completion in
        
      }) { allNames in
        names = allNames
    }
    XCTAssertEqual(names, TestFixtureNames)
  }
  
  func testBackpressure() {
    let sut = NameImporter()
    var names: [NameType] = []
    _ = sut.importFrom(file: NameFile.test)
      .slowSink(receiveCompletion: { completion in
        }) { nextName in
          //collect
          names.append( nextName)
      }
    XCTAssertEqual(names, TestFixtureNames)
  }
  
    func testSpeed() {
      self.measure {
        let sut = NameImporter()
        _ = sut.importFrom(file: NameFile.test).assertNoFailure().makeConnectable().connect()
      }
    }
  
}

/// A simple subscriber that requests an unlimited number of values upon subscription.
public final class SlowSink<Input, Failure: Error>
  : Subscriber,
  Cancellable,
  CustomStringConvertible,
  CustomReflectable,
  CustomPlaygroundDisplayConvertible
{
  
  /// The closure to execute on receipt of a value.
  public let receiveValue: (Input) -> Void
  
  /// The closure to execute on completion.
  public let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
  
  private var _upstreamSubscription: Subscription?
  
  public var description: String { return "Sink" }
  
  public var customMirror: Mirror {
    return Mirror(self, children: EmptyCollection())
  }
  
  public var playgroundDescription: Any { return description }
  
  /// Initializes a sink with the provided closures.
  ///
  /// - Parameters:
  ///   - receiveValue: The closure to execute on receipt of a value. If `nil`,
  ///     the sink uses an empty closure.
  ///   - receiveCompletion: The closure to execute on completion. If `nil`,
  ///     the sink uses an empty closure.
  public init(receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil,
              receiveValue: @escaping ((Input) -> Void)) {
    self.receiveCompletion = receiveCompletion ?? { _ in }
    self.receiveValue = receiveValue
  }
  
  public func receive(subscription: Subscription) {
    if _upstreamSubscription == nil {
      _upstreamSubscription = subscription
      subscription.request(.unlimited)
    } else {
      subscription.cancel()
    }
  }
  
  public func receive(_ value: Input) -> Subscribers.Demand {
    defer {
      usleep(1000)
    }
    receiveValue(value)
    return Subscribers.Demand.max(1)
  }
  
  public func receive(completion: Subscribers.Completion<Failure>) {
    receiveCompletion(completion)
  }
  
  public func cancel() {
    _upstreamSubscription?.cancel()
    _upstreamSubscription = nil
  }
}

extension Publisher {

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// This method creates the subscriber and immediately requests
    /// an unlimited number of values, prior to returning the subscriber.
    /// - parameter receiveValue: The closure to execute on receipt of a value.
    ///   If `nil`, the sink uses an empty closure.
    /// - parameter receiveComplete: The closure to execute on completion.
    ///   If `nil`, the sink uses an empty closure.
    /// - Returns: A cancellable instance; used when you end assignment
    ///   of the received value. Deallocation of the result will tear down
    ///   the subscription stream.
    public func slowSink(
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
        receiveValue: @escaping ((Output) -> Void)
    ) -> AnyCancellable {
        let subscriber = SlowSink<Output, Failure>(
            receiveCompletion: receiveCompletion,
            receiveValue: receiveValue
        )
        subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
}


let TestFixtureNames = [
  
  NameType("Mary","F",7065),
  NameType("Anna","F",2604),
  NameType("Emma","F",2003),
  NameType("Elizabeth","F",1939),
  NameType("Minnie","F",1746),
  NameType("Margaret","F",1578),
  NameType("Ida","F",1472),
  NameType("Alice","F",1414),
  NameType("Bertha","F",1320),
  NameType("Sarah","F",1288),
  NameType("Annie","F",1258),
  NameType("Clara","F",1226),
  NameType("Ella","F",1156),
  NameType("Florence","F",1063),
  NameType("Cora","F",1045),
  NameType("Martha","F",1040),
  NameType("Laura","F",1012),
  NameType("Nellie","F",995),
  NameType("Grace","F",982),
  NameType("Carrie","F",949),
  NameType("Maude","F",859),
  NameType("Mabel","F",808),
  NameType("Bessie","F",796),
  NameType("Jennie","F",793),
  NameType("Gertrude","F",787),
  NameType("Julia","F",783),
  NameType("John","M",9655),
  NameType("William","M",9532),
  NameType("James","M",5927),
  NameType("Charles","M",5348),
  NameType("George","M",5126),
  NameType("Frank","M",3242),
  NameType("Joseph","M",2632),
  NameType("Thomas","M",2534),
  NameType("Henry","M",2444),
  NameType("Robert","M",2415),
  NameType("Edward","M",2364),
  NameType("Harry","M",2152),
  NameType("Walter","M",1755),
  NameType("Arthur","M",1599),
  NameType("Fred","M",1569),
  NameType("Albert","M",1493),
  NameType("Samuel","M",1024),
  NameType("David","M",869),
  NameType("Louis","M",828),
  NameType("Joe","M",731),
  NameType("Charlie","M",730),
  NameType("Clarence","M",730),
  NameType("Richard","M",728),
  NameType("Andrew","M",644),
  NameType("Daniel","M",643),
  NameType("Ernest","M",615),
  NameType("Will","M",588),
  NameType("Jesse","M",569),
  NameType("Oscar","M",544),
  NameType("Lewis","M",517),
  NameType("Peter","M",496),
  NameType("Benjamin","M",490),
  NameType("Frederick","M",483),
  NameType("Willie","M",476),
  NameType("Alfred","M",469),
]
