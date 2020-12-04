import XCTest
@testable import Tape

final class TapeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Tape().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
