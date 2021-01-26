//
//  File.swift
//  
//
//  Created by Precious Osaro on 23/01/2021.
//

import SpeechifyCore
import SwiftUI
import SharedResource

///Screen builder
public class MainViewBuilder: BaseViewBuilderProtocol {
    public static func start() -> AnyView {
        return AnyView(EmptyView())
    }
    
    public class func start(delegate: TranscriberInterface) -> AnyView {
        
        let model = MainModel()
        let viewModel = MainViewModel(state: model)
        viewModel.transcriberDelegate = delegate
       
        return AnyView(MainView(viewModel: viewModel))
    }
}
