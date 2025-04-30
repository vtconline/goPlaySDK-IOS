import SwiftUI

extension Font {
    static func copyWith(
        size: CGFloat = 19,
        weight: Font.Weight = .regular,
        italic: Bool = false,
        smallCaps: Bool = false,
        monospaced: Bool = false,
        customFontName: String? = nil
    ) -> Font {
        var base: Font
        
        // If a custom font is provided, use it
        if let customFontName = customFontName {
            base = .custom(customFontName, size: size)
        } else {
            base = .system(size: size, weight: weight)
            
            if monospaced {
                base = .system(size: size, weight: weight, design: .monospaced)
            }
            
            if italic {
                base = base.italic()
            }
            
            if smallCaps {
                base = base.smallCaps()
            }
        }
        
        return base
    }
}
