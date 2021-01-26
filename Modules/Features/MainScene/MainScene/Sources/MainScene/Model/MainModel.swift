//
//  File.swift
//  
//
//  Created by Precious Osaro on 24/01/2021.
//

import SpeechifyCore
import SharedResource
import Combine

/// Recording state
enum RecordingState {
    case recording
    case preping
    case idle
}

/// Playing state
enum PlayingState {
    case stopped
    case playing
}

/// Model for the main model
struct MainModel: BaseModelProtocol {
    var transcribedTextEnd = Localizable.placeHolderText
    var transcribedTextHighlight = ""
    var transcribedTextStart = "" 
    var recordingState: RecordingState = .idle
    var playingState: PlayingState = .stopped
}
