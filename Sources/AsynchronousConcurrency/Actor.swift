//
//  Actor.swift
//  
//
//  Created by joser on 2021/6/12.
//

import Foundation

@propertyWrapper
public struct Actor<V> {
    private var value:ActorValue<V>
    let semaphore:DispatchSemaphore
    public init(_ value:V? = nil) {
        self.value = ActorValue<V>(value)
        self.semaphore = DispatchSemaphore(value: 1)
    }
    public var wrappedValue:V? {
        get {
            let _ = self.semaphore.wait(wallTimeout: .distantFuture)
            let value = self.value.value
            self.semaphore.signal()
            return value
        }
        nonmutating set {
            let _ = self.semaphore.wait(wallTimeout: .distantFuture)
            self.value.value = newValue
            self.semaphore.signal()
        }
    }
}

fileprivate class ActorValue<V> {
    var value:V?
    init(_ value:V? = nil) {
        self.value = value
    }
}
