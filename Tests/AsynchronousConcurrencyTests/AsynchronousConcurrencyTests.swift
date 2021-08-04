    import XCTest
    import Foundation
    @testable import AsynchronousConcurrency

    final class AsynchronousConcurrencyTests: XCTestCase {
        @Actor(2)
        var age:Int?
        func testExample() {
            Async<Int> {
                /// 你必须解决`Self`循环
                let future1 = self.future1()
                let future2 = self.future2()
                try FutureList([future1,future2]).await()
                let value1 = try future1.await()
                let value2 = try future2.await()
                print("future1 value \(value1)")
                print("future2 value \(value2)")
                return FutureAsyncValue.void
            }.catch({ error in
                print(error.localizedDescription)
            })
            .await()
//            FutureAsync<Int> {
//                let future1 = Future<Int> { handle in
//                    print("future1 \(Thread.current)")
//                    let start = Date().timeIntervalSince1970
//                    DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
//                        print("future1 \(Date().timeIntervalSince1970 - start)")
//                        handle(1)
//                    }
//                }
//                let future2 = Future<Int> { handle in
//                    print("future2 \(Thread.current)")
//                    let start = Date().timeIntervalSince1970
//                    DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
//                        print("future2 \(Date().timeIntervalSince1970 - start)")
//                        handle(2)
//                    }
//                }
//                if let value1 = try? future1.await(), let value2 = try? future2.await()  {
//                    print("future1 value \(value1)")
//                    print("future2 value \(value2)")
//                }
//                return FutureAsyncValue.void
//            }.await()
            
        }
        
        func future1() -> Future<Int> {
            return .init{ success, failure in
                print("future1 \(Thread.current)")
                let start = Date().timeIntervalSince1970
                DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                    print("future1 \(Date().timeIntervalSince1970 - start)")
                    success(1)
                }
            }
        }
        
        func future2() -> Future<Int> {
            return .init { success, failure in
                print("future2 \(Thread.current)")
                let start = Date().timeIntervalSince1970
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                    print("future2 \(Date().timeIntervalSince1970 - start)")
                    success(2)
                }
            }
        }
        
    }
