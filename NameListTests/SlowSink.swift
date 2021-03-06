//
//  SlowSink.swift
//  NameListTests
//
//  Created by Paul Wood on 7/31/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import Combine

/// A simple subscriber that requests an unlimited number of values upon subscription.
/// creates a delayeach time an element is received using `usleep()`
/// Thanks for OpenCombine for providing the boilerplate needed for a Subscriber
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
  
  public let slow: UInt32
  
  private var _upstreamSubscription: Subscription?
  
  public var description: String { return "SlowSink" }
  
  public var customMirror: Mirror {
    return Mirror(self, children: EmptyCollection())
  }
  
  public var playgroundDescription: Any { return description }
  
  /// Initializes a sink with the provided closures.
  ///
  /// - Parameters:
  ///   - slowBy: The time in milliseconds to delay the receiveValue to create artificial backpressure
  ///   - receiveValue: The closure to execute on receipt of a value. If `nil`,
  ///     the sink uses an empty closure.
  ///   - receiveCompletion: The closure to execute on completion. If `nil`,
  ///     the sink uses an empty closure.
  public init(slowBy slow: UInt32 = 1,
              receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil,
              receiveValue: @escaping ((Input) -> Void)) {
    self.receiveCompletion = receiveCompletion ?? { _ in }
    self.receiveValue = receiveValue
    self.slow = slow
  }
  
  public func receive(subscription: Subscription) {
    if _upstreamSubscription == nil {
      _upstreamSubscription = subscription
      subscription.request(.unlimited) // What happens when we return `.none` or `.max(3)`?
    } else {
      subscription.cancel()
    }
  }
  
  public func receive(_ value: Input) -> Subscribers.Demand {
    // What happens if this defer is added? How does that affect the order of work upstream?
//    defer {
      sleep(slow)
//    }
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
    slowBy: UInt32,
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
