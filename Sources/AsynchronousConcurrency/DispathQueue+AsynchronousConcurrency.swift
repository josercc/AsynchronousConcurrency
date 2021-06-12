//
//  DispathQueue+AsynchronousConcurrency.swift
//  
//
//  Created by joser on 2021/6/12.
//

import Foundation

public extension DispatchQueue {
    /// 获取执行异步函数的线程队列
    static let `async` = DispatchQueue(label: "com.AsynchronousConcurrency.async",
                                       attributes: .concurrent)
    /// 获取执行等待函数的线程队列
    static let `await` = DispatchQueue(label: "com.AsynchronousConcurrency.await",
                                       attributes: .concurrent)
}
