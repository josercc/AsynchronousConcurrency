    import XCTest
    import Foundation
    @testable import AsynchronousConcurrency

    final class AsynchronousConcurrencyTests: XCTestCase {
        @Actor(2)
        var age:Int?
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            
//            let future = self.makeFuture(number: 2).map { number in
//                guard let num = Int(number) else {
//                    return nil
//                }
//                return num + 1
//            }.flatMap { num in
//                return self.makeFuture(number: num + 1)
//            }
//            guard let value = try? future.await() else {
//                return
//            }
//            print(value)

        }
        
        
        
    }
