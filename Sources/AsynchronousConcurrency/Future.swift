//
//  Future.swift
//  
//
//  Created by joser on 2021/6/12.
//

import Foundation

/// 异步值存放结构体
public struct Future<V>: FutureAwait {
    /// 设置异步值返回值的回掉
    public typealias Handle = (V?) -> Void
    /// 存放异步获取的值
    private var value:FutureValue<V>
    /// 信号量 用于等待函数值阻断
    let semaphore:DispatchSemaphore
    /// 创建一个从其他值转化为异步值回掉
    let make:(@escaping Handle) -> Void
    /// 初始化一个异步值结构体
    /// - Parameter make: 异步值设置函数
    public init(_ make:@escaping (@escaping Handle) -> Void) {
        self.semaphore = DispatchSemaphore(value: 0)
        self.make = make
        self.value = FutureValue()
    }
    
    /// 获取当钱异步的值 如果当前结构体还没有执行等待函数 则会抛异常
    /// - Returns: 对应的值
    public func get() throws -> V {
        guard self.value.isReadlySet else {
            assertionFailure()
            throw FutureError.futureNotReadly
        }
        guard let value = self.value.value else {
            throw FutureError.futureNotReadly
        }
        return value
    }
    
    /// 执行等待函数获取异步值
    /// - Parameter success: 执行等待完毕的回掉 默认为nil
    /// - Returns: 返回对应异步的值
    public func `await`(_ success: (() -> Void)? = nil) throws -> V {
        _await {
            success?()
            self.semaphore.signal()
        }
        let _ = self.semaphore.wait(wallTimeout: .distantFuture)
        let value = try self.get()
        return value
    }
    
    /// 执行等待函数
    /// - Parameter success: 执行等待完毕的回掉 默认为nil
    public func _await(_ success:(() -> Void)? = nil) {
        DispatchQueue.await.async {
            let handle:Handle = { value in
                self.value.value = value
                success?()
            }
            self.make(handle)
        }
    }
}

/// 扩展
public extension Future {
    typealias MapHandle<T> = (V) -> T?
    typealias FlatMapHandle<T> = (V) -> Future<T>
    /// 将一个未来值转换成另外未来值类型`V->T`
    /// - Returns: 另外的未来值类型
    func map<T>(_ handle:@escaping MapHandle<T>) -> Future<T> {
        return Future<T> { fHandle in
            self._await {
                guard let fValue = try? self.get() else {
                    fHandle(nil)
                    return
                }
                guard let value = handle(fValue) else {
                    fHandle(nil)
                    return
                }
                fHandle(value)
            }
        }
    }
    
    /// 将一个未来值转换为另外的未来值`V->Future<T>`
    /// - Returns: 另外的未来值类型
    func flatMap<T>(_ handle:@escaping FlatMapHandle<T>) -> Future<T> {
        return Future<T> { fHandle in
            self._await {
                guard let fValue = try? self.get() else {
                    return fHandle(nil)
                }
                let future = handle(fValue)
                future._await {
                    guard let fValue = try? future.get() else {
                        return fHandle(nil)
                    }
                    fHandle(fValue)
                }
            }
        }
    }
}


