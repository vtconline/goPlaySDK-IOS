//
//  constants.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 24/4/25.
//

import SwiftUI



public class AppTheme {
    public struct Colors {
        // ✅ UIKit – source of truth
        public static let primaryUIColor   = UIColor(hex: "#5CC9F0")
                public static let secondaryUIColor = UIColor(hex: "#A0D468")
                public static let appleUIColor     = UIColor(hex: "#000000")

                // ✅ SwiftUI – wrap lại
        public static let primary   = Color(primaryUIColor)
                public static let secondary = Color(secondaryUIColor)
                public static let apple     = Color(appleUIColor)
    }
    
    public struct Fonts {
            static let defaultFont: Font = .system(size: 19, weight: .regular)
            static let headline: Font = .headline
            static let title: Font = .title
            // Add more if needed
        }
    public struct Paddings{
        static let  horizontal: CGFloat = 16
    }
    
    public struct Buttons{
        static let  defaultWidth: CGFloat = 300
    }
}
