//
//  FutureAsyncValue.swift
//  
//
//  Created by joser on 2021/6/12.
//

import Foundation

/// 存放异步未来值的返回值
public enum FutureAsyncValue<V> {
    /// 有返回值
    case value(V)
    /// 无返回值
    case void
}
