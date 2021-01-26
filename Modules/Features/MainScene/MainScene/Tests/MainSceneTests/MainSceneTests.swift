import XCTest
@testable import MainScene

final class MainSceneTests: XCTestCase {
    func testSetUp() {
        let viewModel = MainViewModel(state: MainModel())
        viewModel.setup()
        XCTAssertNotEqual(viewModel.state.recordingState, .idle)
        XCTAssertEqual(viewModel.state.playingState, .stopped)
        viewModel.resetRecording()
        XCTAssertEqual(viewModel.state.recordingState, .idle)
    }
    
    func testReset() {
        let viewModel = MainViewModel(state: MainModel())
        viewModel.setup()
        XCTAssertNotEqual(viewModel.state.recordingState, .idle)
        viewModel.resetRecording()
        XCTAssertEqual(viewModel.state.recordingState, .idle)
    }

    static var allTests = [
        ("testSetUp", testSetUp),
        ("testReset", testReset),
    ]
}
