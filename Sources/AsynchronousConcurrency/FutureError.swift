//
//  FutureError.swift
//  
//
//  Created by joser on 2021/6/12.
//

import Foundation

/// 错误处理
public enum FutureError: Error {
    /// 未来值还没有加载完毕
    case futureNotReadly
    /// 自定义其他错误类型
    case custom(String)
    
    public var message:String {
        switch self {
        case .futureNotReadly:
            return "Future data is not ready, please use await synchronization to use"
        case .custom(let message):
            return message
        }
    }
}
