import XCTest
@testable import SpeechifyCore

final class SpeechifyCoreTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SpeechifyCore().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample)
    ]
}
