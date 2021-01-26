//
//  File.swift
//  
//
//  Created by Precious Osaro on 24/01/2021.
//

import SwiftUI
// get tje ed editing call
public extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
         
    }
}
