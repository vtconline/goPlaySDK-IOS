//
//  constants.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 24/4/25.
//

import SwiftUICore



public class AppTheme {
    public struct Colors {
      public static let primary = Color(hex: "#5CC9F0")
      public  static let secondary = Color(hex: "#A0D468")
      public  static let apple = Color(hex: "#000000")
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
}
