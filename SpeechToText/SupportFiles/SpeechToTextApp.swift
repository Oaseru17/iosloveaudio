//
//  SpeechToTextApp.swift
//  SpeechToText
//
//  Created by Precious Osaro on 23/01/2021.
//

import SwiftUI
import MainScene
import SharedResource
import googleapis
import AVFoundation
import SpeechifyCore

@main
struct SpeechToTextApp: App {
    // transcribeCore wasnt created as a weak variable as this app has only one screen
    // and the page exist through out the life cycle
    // ideally the transcribeCore should be created before navigating to the screen where transcribing occurs
    var transcribeCore: TranscribeCore = TranscribeCore()
    var body: some Scene {
        WindowGroup {
            MainViewBuilder.start(delegate: transcribeCore)
        }
    }
    
    func test() {
       
    }
    
}
