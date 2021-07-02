//
//  FutureValue.swift
//  
//
//  Created by joser on 2021/6/12.
//

import Foundation

class FutureValue<V> {
    private(set) var isReadlySet:Bool = false
    var value:V? {
        didSet {
            self.isReadlySet = true
        }
    }
    init() {
        self.value = nil
    }
}
