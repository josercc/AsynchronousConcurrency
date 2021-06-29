//
//  GlobalActor.swift
//  
//
//  Created by joser on 2021/6/12.
//

import Foundation

@propertyWrapper
public struct GlobalActor<V> {
    let key:String
    let `default`:V?
    fileprivate let value:GlobalActionValue
    public init(_ key:String, `default`:V? = nil) {
        self.key = key
        self.default = `default`
        self.value = GlobalActionValue.default
    }
    public var wrappedValue:V? {
        get {
            let _ = self.value.semaphore.wait(wallTimeout: .distantFuture)
            let v = self.value.values[self.key] as? V
            self.value.semaphore.signal()
            return v
        }
        nonmutating set {
            let _ = self.value.semaphore.wait(wallTimeout: .distantFuture)
            self.value.values[self.key] = newValue
            self.value.semaphore.signal()
        }
    }
}

fileprivate class GlobalActionValue {
    fileprivate var values:[String:Any] = [:]
    fileprivate let semaphore:DispatchSemaphore = DispatchSemaphore(value: 1)
    fileprivate static let `default` = GlobalActionValue()
}
