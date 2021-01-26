import XCTest
@testable import SharedUtils

final class SharedUtilsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SharedUtils().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
