    import XCTest
    import Foundation
    @testable import AsynchronousConcurrency

    final class AsynchronousConcurrencyTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            FutureAsync<Int> {
                sleep(2)
                return FutureAsyncValue.value(2)
            }.then { value in
                print("async \(value)")
            }.await()
            
            print("end1")
            
            
        }
    }
