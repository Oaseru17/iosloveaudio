//
//  File.swift
//  
//
//  Created by Precious Osaro on 24/01/2021.
//

import SpeechifyCore
import Combine
import SharedResource
import SwiftUI

/**
 The main screen view model
 **/
class MainViewModel: BaseViewModelProtocol {
    
    /// the state to hold the model
    @Published var state: MainModel
    var transcriberDelegate: TranscriberInterface?
    var recordSubject: AnyCancellable?
    var playBackSubject: AnyCancellable?
    var wordSearchSubject: AnyCancellable?
    
    // for the alert view
    @Published var hasError = false
    @Published var errorMessage = ""
    
    init(state: MainModel) {
        self.state = state
    }
    
    /// Det up the recording session variables
    func setup() {
        self.state.recordingState = .preping
        self.state.playingState = .stopped
    }
    
    // Set the transcriber subject and subscribe
    func startRecording() {
        do {
            self.resetPlayBack()
            try transcriberDelegate?.setup(completion: { [weak self] (publisher) in
                guard let self = self else {
                    return
                }
                self.state.recordingState = .recording
                self.recordSubject =  publisher.sink { (value) in
                    if let error = value.1 {
                        self.hasError = true
                        self.errorMessage = error.localizedDescription
                        self.stopRecording()
                    } else {
                        self.state.transcribedTextEnd = value.0 ?? ""
                        self.state.transcribedTextStart = ""
                        self.state.transcribedTextHighlight =  ""
                    }
                }
            })
        } catch {
            self.stopRecording()
            self.removeRecordingSubscription()
        }
    }
    
    /// Stop the recording process
    func stopRecording() {
        do {
            self.state.recordingState = .idle
            try transcriberDelegate?.stopRecording()
        } catch {
            self.removeRecordingSubscription()
        }
    }
    
    // start the play back process
    func playback() {
        do {
            self.resetRecording()
            self.state.playingState = .playing
            try transcriberDelegate?.playBack(completion: { [weak self] (publisher) in
                guard let self = self else {
                    return
                }
                // begin the find a word loop
                self.findWordSearch()
                self.playBackSubject =  publisher.sink { (value) in
                    if value {
                        self.removePlayingSubscription()
                    }
                }
            })
        } catch {
            self.hasError = true
            self.errorMessage = error.localizedDescription
            self.removePlayingSubscription()
        }
    }
    
    /// Stop and dispose of playback, subscriptions
    func stopPlayback() {
        do {
            self.state.playingState = .stopped
            try transcriberDelegate?.stopPlayBack()
            self.removePlayingSubscription()
        } catch {
            self.removePlayingSubscription()
            self.hasError = true
            self.errorMessage = error.localizedDescription
        }
    }
    
    /// remove play back subscription to subject publishers
    func removePlayingSubscription() {
        wordSearchSubject?.cancel()
        self.state.playingState = .stopped
        self.recordSubject?.cancel()
        self.recordSubject = nil
    }
    
    /// remove recording subscription from subject publishers
    func removeRecordingSubscription() {
        self.recordSubject?.cancel()
        self.recordSubject = nil
    }
    
    /// Reset the playback state
    func resetPlayBack() {
        // reset playback
        do {
            self.removePlayingSubscription()
            try transcriberDelegate?.stopPlayBack()
        } catch {
            self.hasError = true
            self.errorMessage = error.localizedDescription
        }
    }
    
    /// Rest recording state
    func resetRecording() {
        // reset recordun
        self.stopRecording()
        self.removeRecordingSubscription()
        self.state.recordingState = .idle
    }
    
    // find the word triggger
    func findWordSearch() {
        let currentData = Date().timeIntervalSince1970
        wordSearchSubject = Timer.publish(every: 0.001, tolerance: 10, on: .main, in: .common)
            .autoconnect().sink {_ in
                let diffNanoSeconds = Int64((Date().timeIntervalSince1970 - currentData )  * 1000000000)
                let result = self.transcriberDelegate?.getWordToHighlight(currentPoint: diffNanoSeconds)
                if result != nil && result!.count >= 3 {
                    self.setTextinTextView(textInfoToDisplay: result!)
                }
            }
    }
    
    // Set up the view with the required inputts
    func setTextinTextView(textInfoToDisplay: [String]) {
        if textInfoToDisplay.count >= 3 {
            self.state.transcribedTextStart = textInfoToDisplay[0]
            self.state.transcribedTextHighlight = textInfoToDisplay[1]
            self.state.transcribedTextEnd = textInfoToDisplay[2]
        }
    }
    
}
