import SwiftUI
import UIKit
struct AdaptiveVerticalAlignment: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            content
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: isLandscape ? .center : .top
                )
        }
    }
}

extension View {
    @ViewBuilder
    func adaptiveVerticalAlignment() -> some View {
        if #available(iOS 15.0, *){
            self.modifier(AdaptiveVerticalAlignment())
        }else{
            self
        }
        
    }
}
