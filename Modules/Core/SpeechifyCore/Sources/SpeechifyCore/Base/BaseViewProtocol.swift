//
//  BaseViewProtocol.swift
//  
//
//  Created by Precious Osaro on 23/01/2021.
//

import Foundation
import SwiftUI

public protocol BaseViewProtocol: View {
    associatedtype ViewModelType: BaseViewModelProtocol
    var viewModel: ViewModelType { get }
}

extension BaseViewProtocol {
}
