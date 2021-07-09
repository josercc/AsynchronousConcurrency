    import XCTest
    import Foundation
    @testable import AsynchronousConcurrency

    final class AsynchronousConcurrencyTests: XCTestCase {
        @Actor(2)
        var age:Int?
        func testExample() {

            Async<Void> {
                let future:Future<Int> = .init { success, failure in
                    success(2)
                }.map { _ in
                    return 3
                }.flatMap { _ in
                    throw FutureError.systemError
                }
                try FutureList([self.fututr2()]).await()
                return .void
            }.then {
                print("then")
            }.catch { e in
                print("catch \(e)")
            }.await(queue: .global())
            
            let group = DispatchGroup()
            group.enter()
            group.wait(wallTimeout: .distantFuture)
            
        }
        
        func future1() -> Future<Int> {
            return .init { success, failure in
                throw FutureError.systemError
            }
        }
        
        func fututr2() -> Future<String> {
            return .init { success, failure in
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    failure(FutureError.futureNotReadly)
                }
            }
        }
        
    }
