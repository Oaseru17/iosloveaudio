//
//  SpeechRecognitionService.swift
//  SpeechToText
//
//  Created by Precious Osaro on 24/01/2021.
//

import Foundation
import googleapis
/// Speech recognition injector
protocol SpeechRecognitionInjector {
    var speedRegService: SpeechRecognitionService { get }
}
fileprivate let sharedSpeechServiceManager: SpeechRecognitionService = SpeechRecognitionService()
extension SpeechRecognitionInjector {
    var speedRegService: SpeechRecognitionService {
        return sharedSpeechServiceManager
    }
}

let APIKEY = "AIzaSyAce7hHtGJgsf4beLYtAX8OoZfC_Lpy9KE"
let HOST = "speech.googleapis.com"

typealias SpeechRecognitionCompletionHandler = (StreamingRecognizeResponse?, NSError?) -> Void

open class SpeechRecognitionService {
    var sampleRate: Int = 41000
  private var streaming = false

  private var client: Speech!
  private var writer: GRXBufferedPipe!
  private var call: GRPCProtoCall!

  func streamAudioData(_ audioData: NSData, completion: @escaping SpeechRecognitionCompletionHandler) {
    if !streaming {
      // check if streaming is active
      // set up
      client = Speech(host: HOST)
      writer = GRXBufferedPipe()
      call = client.rpcToStreamingRecognize(
        withRequestsWriter: writer, eventHandler: { (_, response, error) in
            completion(response, error as NSError?)
      })
      // authenticate using an API key obtained from the Google Cloud Console
      call.requestHeaders.setObject(NSString(string: APIKEY),
                                    forKey: NSString(string: "X-Goog-Api-Key"))
      // if the API key has a bundle ID restriction, specify the bundle ID like this
      call.requestHeaders.setObject(NSString(string: Bundle.main.bundleIdentifier!),
                                    forKey: NSString(string: "X-Ios-Bundle-Identifier"))

      call.start()
      streaming = true

      // send an initial request message to configure the service
      let recognitionConfig = RecognitionConfig()
      recognitionConfig.encoding =  .linear16
      recognitionConfig.sampleRateHertz = Int32(sampleRate)
      recognitionConfig.languageCode = "en-US"
      recognitionConfig.maxAlternatives = 30
      recognitionConfig.enableWordTimeOffsets = true

      let streamingRecognitionConfig = StreamingRecognitionConfig()
      streamingRecognitionConfig.config = recognitionConfig
      streamingRecognitionConfig.singleUtterance = false
      streamingRecognitionConfig.interimResults = true

      let streamingRecognizeRequest = StreamingRecognizeRequest()
      streamingRecognizeRequest.streamingConfig = streamingRecognitionConfig

      writer.writeValue(streamingRecognizeRequest)
    }

    // send a request message containing the audio data
    let streamingRecognizeRequest = StreamingRecognizeRequest()
    streamingRecognizeRequest.audioContent = audioData as Data
    writer.writeValue(streamingRecognizeRequest)
  }

  func stopStreaming() {
    if !streaming {
      return
    }
    writer.finishWithError(nil)
    streaming = false
  }

  func isStreaming() -> Bool {
    return streaming
  }

}
