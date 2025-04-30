

import SwiftUI
import AuthenticationServices

public struct CustomAppleSignInButton: View {
    var title: String
    var width: CGFloat?
    var useDefaultWidth: Bool
    var action: (() -> Void)?

    public init(
        title: String = "Sign in with Apple",
        width: CGFloat? = nil,
        useDefaultWidth: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.width = width
        self.useDefaultWidth = useDefaultWidth
        self.action = action
    }
    
    public var body: some View {
        GoButton(
            text: title,
            color: Color.black, // Apple's button is black
            borderColor: nil,
            textColor: .white,
            iconSysColor: .white,
            fontSize: 17,
            width: width,
            useDefaultWidth: useDefaultWidth,
            iconName: "apple.logo",
            isSystemIcon: true,
            
            action: action
        )
    }
    
    
}
