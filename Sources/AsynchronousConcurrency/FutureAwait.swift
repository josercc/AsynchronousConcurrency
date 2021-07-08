//
//  FutureAwait.swift
//  
//
//  Created by joser on 2021/6/12.
//

import Foundation

/// 执行等待的协议
public protocol FutureAwait {
    /// 异步函数执行完毕
    typealias FutureAwaitCompletion = (FutureAwait) -> Void
    /// 执行等待函数
    /// - Parameter success: 等待之后完成的回掉
    func _await(_ success:FutureAwaitCompletion?)
}
