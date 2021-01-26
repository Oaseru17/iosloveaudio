//
//  File.swift
//  
//
//  Created by Precious Osaro on 24/01/2021.
//

import SwiftUI

public enum AppFonts {
    public static func regular(_ size: Int) -> Font {
        return Font.custom("NunitoSans-Regular", size: CGFloat(size))
    }
    
    public static func semiBold(_ size: Int) -> Font {
        return Font.custom("NunitoSans-SemiBold", size: CGFloat(size))
    }
    
    public static func bold(_ size: Int) -> Font {
        return Font.custom("NunitoSans-Bold", size: CGFloat(size))
    }
    
    public static func black(_ size: Int) -> Font {
        return Font.custom("NunitoSans-Black", size: CGFloat(size))
    }
}
