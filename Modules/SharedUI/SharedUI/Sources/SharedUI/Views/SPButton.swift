//
//  SPButton.swift
//  
//
//  Created by Precious Osaro on 24/01/2021.
//

import SwiftUI
import SharedResource

// Base Button view
public struct SPButton: View {
    var title: String
    var action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    public var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(AppFonts.bold(17))
                Spacer()
            }
        }
    }
}
