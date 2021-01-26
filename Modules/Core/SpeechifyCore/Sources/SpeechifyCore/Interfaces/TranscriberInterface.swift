/// This class allows other modules interface with the application
import Combine

/// the transcriber interface connects the modelview to the core transcriber egine
public protocol TranscriberInterface {
    func setup(completion: @escaping (AnyPublisher<(String?, Error?), Never>) -> Void) throws
    func stopRecording() throws
    func playBack(completion: @escaping (AnyPublisher<Bool, Never>) -> Void) throws
    func stopPlayBack() throws
    func getWordToHighlight(currentPoint: Int64) -> [String]
}
