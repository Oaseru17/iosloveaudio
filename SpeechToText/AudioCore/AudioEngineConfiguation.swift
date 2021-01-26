//
//  File.swift
//  
//
//  Created by Precious Osaro on 25/01/2021.
//

import AVFoundation

// the Audio engine configuration
class AudioEngineConfiguation {
    static let sampleRate = 16000 // the sample rate
    
    class func getConf() -> AudioStreamBasicDescription {
    var config = AudioStreamBasicDescription()
        config.mSampleRate = Float64(sampleRate)
        config.mFormatID = kAudioFormatLinearPCM
        config.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
        config.mBytesPerPacket = 2
        config.mFramesPerPacket = 1
        config.mBytesPerFrame = 2
        config.mChannelsPerFrame = 1
        config.mBitsPerChannel = 16
        return config
    }
}

enum AudioEngine: Error {
    case fileNotFound
}
