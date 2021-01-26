//
//  File.swift
//  
//
//  Created by Precious Osaro on 25/01/2021.
//

import Foundation
// Error
public enum TranscriberError: Error {
    case noRecordingURL
}

extension TranscriberError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noRecordingURL:
            return "No audio recording. Please begin a recording session before playing"
        }
    }
}
