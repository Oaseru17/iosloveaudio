//
//  Styling + Button.swift
//
//
//  Created by Precious Osaro on 24/01/2021.
//

import SwiftUI
import SharedResource

// Base button styling
public struct BaseButtonStyling: ButtonStyle {
    let color: Color
    public init(color: Color) {
        self.color = color
    }
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(configuration.isPressed ? .gray : .white)
            .padding()
            .background(color)
            .cornerRadius(30)
            .frame(height: 45)
    }
}
