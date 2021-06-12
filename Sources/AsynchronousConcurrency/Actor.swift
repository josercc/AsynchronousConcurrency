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
        self.semaphore = DispatchSemaphore(value: 0)
    }
    public var wrappedValue:V? {
        get {
            return self.value.value
        }
        nonmutating set {
            DispatchQueue.await.async {
                self.value.value = newValue
                self.semaphore.signal()
            }
            let _ = self.semaphore.wait(wallTimeout: .distantFuture)
        }
    }
}

fileprivate class ActorValue<V> {
    var value:V?
    init(_ value:V? = nil) {
        self.value = value
    }
}
