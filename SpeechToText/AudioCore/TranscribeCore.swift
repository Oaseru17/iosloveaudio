//
//  TranscribeCore.swift
//  SpeechToText
//
//  Created by Precious Osaro on 25/01/2021.
//

import Foundation
import SpeechifyCore
import Combine
import SwiftUI
import AVFoundation
import googleapis

/**
 The Transcribe Core class handle the following
 1. The recording progress
 2, The playback calls aswell as the text highlighting
 */
public class TranscribeCore: TranscriberInterface, AudioControllerDelegate, AudioManagerInjector, SpeechRecognitionInjector {
   
    //: Mark State plublishers
    var publishTranslated: PassthroughSubject<(String?, Error?), Never>?
    var publishPlayingState: PassthroughSubject<Bool, Never>?
    
    //: Mark audio manager variables
    var audioData: NSMutableData!
    var audioEngine: AVAudioEngine = AVAudioEngine()
    var audioFilePlayer: AVAudioPlayerNode = AVAudioPlayerNode()
    
    //: Mark variables required for play back
    private var safeCover = ""
    var wordsInfo: [WordInfo] = []
    private var remainWords: [WordInfo] = []
    private var playedWords: [WordInfo] = []
    
    // s
    public func setup(completion: @escaping (AnyPublisher<(String?, Error?), Never>) -> Void) throws {
        publishTranslated = PassthroughSubject<(String?, Error?), Never>()
        completion(publishTranslated!.eraseToAnyPublisher())
        safeCover = ""
        wordsInfo = []
        remainWords = []
        playedWords = []
        try initRecording()
    }
    
    /// init the record process
    /// setting up rates
    private func initRecording() throws {
        speedRegService.sampleRate = Int(audioManager.sampleRate)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            audioData = NSMutableData()
           // try audioSession.setPreferredSampleRate(Double(AudioEngineConfiguation.sampleRate))
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            audioManager.delegate = self
            try audioManager.startRecording()
        } catch {
            throw error
        }
    }
    
    /// stop recording
    public func stopRecording() throws {
        audioManager.stopRecording()
        speedRegService.stopStreaming()
    }
    
    /// begin playing the audio file
    public func playBack(completion: @escaping (AnyPublisher<Bool, Never>) -> Void) throws {
        publishPlayingState = PassthroughSubject<Bool, Never>()
        completion(publishPlayingState!.eraseToAnyPublisher())
        remainWords = wordsInfo
        playedWords = []
        safeCover = ""
        try audioManager.playRecord()
    }
    
    /// stop audio player
    public func stopPlayBack() {
        audioManager.stopRecord()
    }
    
    func audioFinishedPlaying() {
        publishPlayingState?.send(true)
    }

    /// get word highlifhts
    public func getWordToHighlight(currentPoint: Int64) -> [String] {
        var foundIndex = (0, false)
        /// get the first word without search
        if currentPoint <= 0 && (self.remainWords.count == self.wordsInfo.count) {
            foundIndex = (0, true)
        } else {
            for (index, value) in remainWords.enumerated() {
                if index == 0 && !value.hasStartTime {
                    foundIndex = (0, true)
                    break
                } else if value.hasStartTime && value.hasEndTime { /// makes sure word has start and endtime
                    let startValue = Int64(value.startTime.nanos) + Int64(value.startTime.seconds * 1000000000) /// convert time to nanseconds
                    let endValue = Int64(value.endTime.nanos) + Int64(value.endTime.seconds * 1000000000)/// convert time to nanseconds
                    if startValue <= currentPoint && endValue >= currentPoint {
                        foundIndex = (index, true)
                        break
                    }
                }
            }
        }
        if foundIndex.1 {
            /// reduce the time required to find word by splitting into array
            self.playedWords = Array(wordsInfo[0..<(wordsInfo.count - remainWords.count)])
            let leftover = remainWords[(foundIndex.0 + 1)..<remainWords.count]
            let word = remainWords[foundIndex.0]
            remainWords = Array(leftover)
            
            return [self.playedWords.compactMap { $0.word}.joined(separator: " "), " \(word.word ?? "") ", self.remainWords.compactMap { $0.word}.joined(separator: " ")]
        }
        return []
    }
    
    /// sample data delegate
    func processSampleData(_ data: Data) {
        audioData.append(data)
        let chunkSize: Int  = Int( 2 * Double(audioManager.sampleRate) )
        if audioData.length > chunkSize {
            speedRegService.streamAudioData(audioData, completion: { (response, error) in
            if let error = error {
              self.publishTranslated?.send((nil, error))
            } else if let response = response {
                var finished = false
                for result in response.resultsArray! {
                    if let result = result as? StreamingRecognitionResult {
                        let resutltData = ((result.alternativesArray[0] as?
                              SpeechRecognitionAlternative)?.transcript.lowercased() ?? "")
                        self.publishTranslated?.send((self.safeCover + resutltData, nil))
                        if result.isFinal {
                            finished = true
                        }
                    }
                }
                
                if finished {
                    if let finalSentence = ( response.resultsArray[0] as? StreamingRecognitionResult )?.alternativesArray[0] as? SpeechRecognitionAlternative, let wordArray = finalSentence.wordsArray as? [WordInfo] {
                        self.safeCover += finalSentence.transcript.lowercased()
                        self.publishTranslated?.send((nil, nil))
                        self.wordsInfo.append(contentsOf: wordArray)
                    }
                }
            }
        })
            self.audioData = NSMutableData()
        }
    }
    
    func audioInterrupted() {
        // Todo: Handle audio player interuption
        // not required yet as no setting is affect, and ausio auto resumes
    }
    
    func audioInterruptedEnded() {
        // Todo: Handle audio player interuption end
        // not required yet as no setting is affect, and ausio auto resumes
    }
    
}
