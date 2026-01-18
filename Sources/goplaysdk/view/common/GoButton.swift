
/**
 sample1
 GoButton(
 color:AppTheme.Colors.secondary,
 action: {
 print("Button tapped!")
 }
 ) {
 HStack {
 Image(systemName: "arrow.right.circle.fill")
 .resizable()
 .scaledToFit()
 .frame(width: 20, height: 20)
 
 Text("Login with Google")
 .font(.headline)
 }
 }
 
 sample1
 GoButton(
 text: "Login with Google",
 iconName: "arrow.right.circle.fill",
 action: {
 print("Button tapped!")
 }
 )
 */
import SwiftUI

public struct GoButton<Content: View>: View {
    let color: Color
    let borderColor: Color?
    let width: CGFloat?
    let useDefaultWidth: Bool
    let padding: EdgeInsets?
    let action: (() -> Void)?
    let content: () -> Content
    
    private var paddingHorizontal: CGFloat = 16
    
    public init(
        color: Color = AppTheme.Colors.primary,
        borderColor: Color? = nil,
        padding: EdgeInsets? = nil,
        width: CGFloat? = nil,
        useDefaultWidth: Bool = true,
        action: (() -> Void)? = nil,
        content: @escaping () -> Content
    ) {
        self.color = color
        self.padding = padding
        self.width = width
        self.action = action
        self.content = content
        self.borderColor = borderColor
        self.useDefaultWidth = useDefaultWidth
    }
    
    public var body: some View {
        Button(action: {
            action?()
        }) {
            content()
                .padding(padding == nil ? EdgeInsets(top: 12, leading:12, bottom: 12, trailing: 12) : padding!)
                .frame(
                    maxWidth: width ?? (useDefaultWidth ? min(
                        UIScreen.main.bounds.width - 2 * paddingHorizontal,
                        300
                    ) : nil)
                )
                .background(color)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor ?? Color.clear, lineWidth: borderColor != nil ? 1 : 0)
                )
        }
        .contentShape(Rectangle())
//        .buttonStyle(.PrimitiveButtonStyle)

    }
}

// MARK: - Convenience initializer for text + icon fallback using AnyView

public extension GoButton where Content == AnyView {
    init(
        text: String,
        color: Color = AppTheme.Colors.primary,
        borderColor: Color? = nil,
        padding: EdgeInsets? = nil,
        textColor: Color = .white,
        iconSysColor: Color = .white,
        fontSize: CGFloat = 19,
        width: CGFloat? = nil,
        useDefaultWidth: Bool = true,
        iconName: String? = nil,
        isSystemIcon: Bool = true,
        iconSize:CGFloat = 19,
        iconPadding: EdgeInsets = EdgeInsets(),
        action: (() -> Void)? = nil
    ) {
        self.init(color: color, borderColor: borderColor, padding: padding,width: width, useDefaultWidth: useDefaultWidth,action: action) {
            AnyView(
                HStack {
                    if isSystemIcon {
                        if let iconName = iconName {
                            Image(systemName: iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconSize, height: iconSize)
                                .foregroundColor(iconSysColor)
                                .clipped()
                                .padding(iconPadding)
                        }
                    } else {
                        if let icon = iconName,
                           let image = UIImage(named: icon, in: Bundle.goplaysdk, compatibleWith: nil) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconSize, height: iconSize)
                                .clipped()
                                .padding(iconPadding)
                        }
                    }
                    
                    if(!text.isEmpty){
                        Text(text)
                            .font(Font.copyWith(size: fontSize))
                            .foregroundColor(textColor)
                    }
                }
            )
        }
    }
}
