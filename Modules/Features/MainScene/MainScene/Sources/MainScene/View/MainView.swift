//
//  SwiftUIView.swift
//  
//
//  Created by Precious Osaro on 23/01/2021.
//

import SwiftUI
import SpeechifyCore
import SharedResource
import SharedUI
import SpeechifyExtension

/**
 The main View for the application
 */
struct MainView: BaseViewProtocol {
    typealias ModelView = MainViewModel
    
    @ObservedObject
    var viewModel: MainViewModel
    
    //: Mark - Propertiodees
    @State var counter: Int = 3 // the counter down animation timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // : Mark View
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                
                Titleheader() //: Title Text
                ScrollView {
                    (Text(viewModel.state.transcribedTextStart) +
                    Text(viewModel.state.transcribedTextHighlight).foregroundColor(Color(Asset.primary.color)) +
                    Text(viewModel.state.transcribedTextEnd))
                        .accessibility(identifier: "transcribedText")
                        .frame(maxWidth: .infinity, alignment: .leading) //: TextView
                }
                .padding(.all, 10).overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(Asset.seconday.color), lineWidth: 2))//: ScrollView
                
                HStack( spacing: 10) {
                    SPButton(title: ($viewModel.state.recordingState.wrappedValue == RecordingState.idle)
                                ? Localizable.record : Localizable.recording ) {
                        withAnimation(.easeInOut(duration: 0.7)) {
                            recordAction()
                        }
                    }.accessibility(identifier: "recordBtn")
                    .buttonStyle(BaseButtonStyling(color: Color(Asset.primary.color)))
                    .accessibility(label: Text("Record button, controls the recording and playback"))
                    .accessibilityAction {
                        recordAction()
                    }//: Record Button
                    
                    SPButton(title: ($viewModel.state.playingState.wrappedValue == PlayingState.stopped)
                                ? Localizable.play : Localizable.stop ) {
                        
                        playAction()
                    }.buttonStyle(BaseButtonStyling(color: viewModel.loadingText ? Color(Asset.grayText.color) : Color(Asset.seconday.color)))
                    .accessibility(label: Text("Play back after recording"))
                    .accessibilityAction {
                        playAction()
                    }//: Play Action
                }  //: HStack end
            }.padding([.leading, .bottom, .trailing], 20).padding(.top, 50) //: VStack end
            .onTapGesture {
                self.endEditing()
            }
            if $viewModel.state.recordingState.wrappedValue == .preping {
                HStack(spacing: 20) {
                    
                    VStack {
                        Text("Ready")
                            .font(AppFonts.semiBold(15))
                            .foregroundColor(Color(Asset.primary.color))
                        Text("\(counter)")
                            
                            .font(AppFonts.black(30))
                            .foregroundColor(Color(Asset.blackText.color))
                            .onReceive(timer) { _ in
                                self.counter -= 1
                                if self.counter <= 0 {
                                    self.timer.upstream.connect().cancel()
                                    self.counter = 3
                                    viewModel.startRecording()
                                }
                            
                            }
                    }.background(RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray).frame(width: 100, height: 100))
                } .frame(minWidth: 0,
                         maxWidth: .infinity,
                         minHeight: 0,
                         maxHeight: .infinity,
                         alignment: .center
                ).background(Color.black.opacity(0.75))
            }
        }.edgesIgnoringSafeArea(.all)
        .alert(isPresented: $viewModel.hasError) {
            Alert(title: Text(""), message: Text(viewModel.errorMessage), dismissButton: .default(Text("Ok")))
        }
        
    }
    
    // returned the grouped time view
    // the is required approach as SwiftUI doesn;t yet suppoer attribute string
    // and i intead to stick to the support UI objects unless when no alternative is avaiable
    func returnGroupedTextView(start: String, highlight: String, end: String) -> Text {
        return Text(start) + Text(" \(highlight) ").foregroundColor(Color(Asset.primary.color)) + Text(end)
    }
    
    /// This function begins the play process
    func playAction() {
        switch $viewModel.state.playingState.wrappedValue {
        case .playing:
            viewModel.stopPlayback() // stop the playback pro
        case.stopped:
            viewModel.playback() // restart or begin playinf
        }
    }
    
    /// This function begins the recording process
    func recordAction() {
        switch $viewModel.state.recordingState.wrappedValue {
        case .recording: // stop recording if currently recording
            viewModel.stopRecording()
        case .preping: // start recording if preped
            viewModel.startRecording()
        case .idle: // set up the recording flow
            viewModel.setup()
             _ = self.timer.upstream.autoconnect()
        }
    }
    
}

// View Component
// Best for static views
private struct Titleheader: View {
    @ViewBuilder public var body: some View {
        Text(Localizable.title)
            .padding(.all, 10)
            .font(AppFonts.semiBold(17))
            .multilineTextAlignment(.center)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MainModel()
        let viewModel = MainViewModel(state: model)
        return MainView(viewModel: viewModel)
    }
}
