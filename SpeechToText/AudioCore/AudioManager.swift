//
//  AudioCore.swift
//  SpeechToText
//
//  Created by Precious Osaro on 24/01/2021.
//

import AVFoundation
import SpeechifyExtension
import SpeechifyCore

// inection protocol
protocol AudioManagerInjector {
    var audioManager: AudioManager { get }
}
fileprivate let sharedAudioDataManager: AudioManager = AudioManager()
extension AudioManagerInjector {
    var audioManager: AudioManager {
        return sharedAudioDataManager
    }
}

var audioPlayer: AVAudioPlayer!
/// This class is to handle the interaction with the audio engine
class AudioManager: NSObject {
    // the current recording state for the audio manager
    enum RecordingState {
        case recording, paused, stopped
    }
    
    fileprivate var isInterrupted = false
    fileprivate var configChangePending = false
    
    // delegate for feedback on data
    var delegate: AudioControllerDelegate?
    
    //: Mark properties
    private var engine: AVAudioEngine!
    private var mixerNode: AVAudioMixerNode!
    private var state: RecordingState = .stopped
    
    // the save recording URL
    var recordingURL: URL?
    
    override init() {
        super.init()
        // set up the session
        setupSession()
        setupEngine()
        registerForNotifications()
    }
    
    deinit {
        // release resources and data
        try? clearRecording()
        if state != .stopped {
            stopRecording()
        }
    }
    
    /// Set up the sestion for recording
    fileprivate func setupSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord) // set as play and record so play back is possible
        try? session.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    /// init the required engine instances
    fileprivate func setupEngine() {
        engine = AVAudioEngine()
        mixerNode = AVAudioMixerNode()
        
        // Set volume to 0 to avoid audio feedback while recording.
        mixerNode.volume = 0
        engine.attach(mixerNode)
        makeConnections()
        // Prepare the engine in advance, in order for the system to allocate the necessary resources.
        engine.prepare()
    }
    
    /// make the connection for the required nodes
    fileprivate func makeConnections() {
        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        engine.connect(inputNode, to: mixerNode, format: inputFormat)
        
        // set the format
        var config = AudioEngineConfiguation.getConf()
        let mainMixerNode = engine.mainMixerNode
        let mixerFormat = AVAudioFormat( streamDescription: &config)
        
        engine.connect(mixerNode, to: mainMixerNode, format: mixerFormat)
    }
    
    func startRecording() throws {
        let tapNode: AVAudioNode = mixerNode
        let format = tapNode.outputFormat(forBus: 0)
        
        // set the format
        var config = AudioEngineConfiguation.getConf()
        let mixerFormat = AVAudioFormat( streamDescription: &config)
        
        recordingURL  = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("speechifyTestRecording.caf")
        let file = try AVAudioFile(forWriting: recordingURL!, settings: mixerFormat!.settings, commonFormat: .pcmFormatInt16, interleaved: true)
        
        tapNode.installTap(onBus: 0, bufferSize: 1024, format: format, block: { (buffer, _ ) in
            // send back the data
            try? self.delegate?.processSampleData(Data(buffer: buffer))
            try? file.write(from: buffer)
        })
        
        // on success set the state
        state = .recording
        
        guard !engine.isRunning else {
            return
        }
        // start the enfine
        try engine.start()
        
    }
    
    /// resume recording
    func resumeRecording() throws {
        try engine.start()
        state = .recording
    }
    
    /// pause the recording session
    func pauseRecording() {
        engine.pause()
        state = .paused
    }
    
    /// stop the recording session
    /// remove all nodes
    func stopRecording() {
        engine.inputNode.removeTap(onBus: 0)
        // remove existing taps on nodes
        mixerNode.removeTap(onBus: 0)
        // stop the engine
        engine.stop()
        state = .stopped
    }
    
    /// remove recording file
    func clearRecording() throws {
        // clear the recording
        let fileManager = FileManager.default
        if let filePath = recordingURL?.absoluteString, fileManager.fileExists(atPath: filePath) {
            try? fileManager.removeItem(atPath: filePath)
        } else {
            throw AudioEngine.fileNotFound
        }
    }
    
    /// play the recording fiels
    func playRecord() throws {
        do {
            if let url = recordingURL {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.prepareToPlay()
                audioPlayer.delegate = self
                audioPlayer.play()
            } else {
                throw TranscriberError.noRecordingURL
            }
        } catch {
            throw error
        }
    }
    
    /// stop the audio player
    func stopRecord() {
        audioPlayer?.stop()
    }
    
    /// get the current time in the playing instance
    func getCurrentTime() -> TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }
    
    /// register for notification
    /// important to ducking audio
    fileprivate func registerForNotifications() {
        _ = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: nil
        ) { [weak self] (notification) in
            guard let self = self else {
                return
            }
            
            let userInfo = notification.userInfo
            let interruptionTypeValue: UInt = userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt ?? 0
            let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeValue)!
            
            switch interruptionType {
            case .began:
                self.isInterrupted = true
                
                if self.state == .recording {
                    self.pauseRecording()
                }
            case .ended:
                self.isInterrupted = false
                
                // Activate session again
                try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                
                self.handleConfigurationChange()
                
                if self.state == .paused {
                    try? self.resumeRecording()
                }
            @unknown default:
                break
            }
        }
        
        _ = NotificationCenter.default.addObserver(
            forName: AVAudioSession.mediaServicesWereResetNotification,
            object: nil,
            queue: nil
        ) { [weak self] (_ ) in
            guard let self = self else {
                return
            }
            
            self.setupSession()
            self.setupEngine()
        }
    }
    
    fileprivate func handleConfigurationChange() {
        if configChangePending {
            makeConnections()
        }
        configChangePending = false
    }
    
}

extension AudioManager: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.delegate?.audioFinishedPlaying()
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        self.delegate?.audioInterrupted()
        
    }
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        self.delegate?.audioInterruptedEnded()
    }
}
