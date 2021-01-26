//
//  AudioDelegate.swift
//  SpeechToText
//
//  Created by Precious Osaro on 25/01/2021.
//

import Foundation
protocol AudioControllerDelegate {
  func processSampleData(_ data: Data) throws
  func audioFinishedPlaying()
  func audioInterrupted()
  func audioInterruptedEnded()
}
