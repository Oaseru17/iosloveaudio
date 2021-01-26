//
//  File.swift
//  
//
//  Created by Precious Osaro on 25/01/2021.
//

import Foundation
import AVFoundation
/// Extension on the Data class
public extension Data {
    init(buffer: AVAudioPCMBuffer) {
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        self.init(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
    }
}
