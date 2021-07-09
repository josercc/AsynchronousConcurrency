//
//  FutureList.swift
//  
//
//  Created by joser on 2021/6/12.
//

import Foundation

/// 并发执行一组异步任务
public class FutureList {
    /// 还需要等待任务的总数
    var awaitCount:Int {
        didSet {
            if self.awaitCount == 0 {
                self.semaphore.signal()
            }
        }
    }
    /// 存放需要执行并发的任务
    let futures:[FutureAwait]
    /// 进行阻断信号量
    let semaphore:DispatchSemaphore
    /// 初始化一个并发异步任务数组
    /// - Parameter futures: 异步任务组
    public init(_ futures:[FutureAwait]) {
        self.futures = futures
        self.awaitCount = self.futures.count
        self.semaphore = DispatchSemaphore(value: 0)
    }
    
    /// 某个异步执行完毕的回掉
    public typealias FutureAwaitCompletion = (FutureAwait) -> Void
    /// 等待全部完成
    public func `await`() throws -> Void {
        assert(self.futures.count > 0, "FutureList count must be > 0")
        var awaitError:Error?
        self.futures.forEach { element in
            element._await { value in
                self.awaitCount -= 1
            } failure: { error in
                awaitError = error
                self.awaitCount = 0
            }
        }
        let _ = self.semaphore.wait(wallTimeout: .distantFuture)
        if let error = awaitError {
            throw error
        }
    }
}
