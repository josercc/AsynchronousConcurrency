//
//  FutureAsync.swift
//  
//
//  Created by joser on 2021/6/12.
//

import Foundation


public typealias FutureAsync = Async

/// 创建一个异步未来值
public struct Async<V> {
    public typealias Handle = () throws -> FutureAsyncValue<V>
    let handle:Handle
    var thenValue:((V) -> Void)?
    var then:(() -> Void)?
    var `catch`:((Error) -> Void)?
    /// 初始化一个异步未来值
    /// - Parameter handle: 获取未来值的逻辑回掉 在子线程处理任务
    public init(_ handle:@escaping Handle) {
        self.handle = handle
    }
    
    /// 执行成功的回掉
    /// - Parameter thenValue: 有返回值成功的回掉
    /// - Returns: FutureAsync<V>
    public func then(_ thenValue:@escaping (V) -> Void) -> Async<V> {
        var future = self
        future.thenValue = thenValue
        return future
    }
    
    /// 执行成功回掉
    /// - Parameter then: 无返回值成功的回掉
    /// - Returns: FutureAsync<V>
    public func then(_ then:@escaping () -> Void) -> Async<V> {
        var future = self
        future.then = then
        return future
    }
    
    
    /// 捕获异常的回掉
    /// - Parameter `catch`: 异常捕获的回掉
    /// - Returns: FutureAsync<V>
    public func `catch`(_ `catch`:@escaping (Error) -> Void) -> Async<V> {
        var future = self
        future.catch = `catch`
        return future
    }
    
    /// 执行等待完成任务
    public func `await`(queue:DispatchQueue = DispatchQueue.main) {
        DispatchQueue.async.async {
            do {
                let value = try self.handle()
                queue.async {
                    switch value {
                    case .value(let v):
                        self.thenValue?(v)
                    case .void:
                        self.then?()
                    }
                }
            } catch(let error) {
                queue.async {
                    self.catch?(error)
                }
            }
        }
    }
}

