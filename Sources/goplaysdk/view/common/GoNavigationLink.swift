import SwiftUI

public struct GoNavigationLink<Destination: View>: View {
    let destination: Destination
    let text: String
    let systemImageName: String?
    let assetImageName: String?
    let imageSize: CGSize
    let font: Font
    let textColor: Color
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let verticalPadding: CGFloat
    let width: CGFloat?

    public init(
        text: String,
        destination: Destination,
        systemImageName: String? = nil,
        assetImageName: String? = nil,
        width: CGFloat? = nil,
        imageSize: CGSize = CGSize(width: 20, height: 20),
        font: Font = .headline,
        textColor: Color = .white,
        backgroundColor: Color = AppTheme.Colors.primary,
        cornerRadius: CGFloat = 10,
        verticalPadding: CGFloat = 16
    ) {
        self.text = text
        self.destination = destination
        self.systemImageName = systemImageName
        self.assetImageName = assetImageName
        self.imageSize = imageSize
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.verticalPadding = verticalPadding
        self.width = width
    }

    public var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 8) {
                if let systemImageName = systemImageName {
                    Image(systemName: systemImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize.width, height: imageSize.height)
                        .foregroundColor(textColor)
                } else if let assetImageName = assetImageName,
                          let image = UIImage(named: assetImageName, in: Bundle.goplaysdk, compatibleWith: nil) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize.width, height: imageSize.height)
                        .clipped()
                }

                if(!text.isEmpty){
                    Text(text)
                        .font(font)
                        .foregroundColor(textColor)
                }
            }
//            .padding()
            .padding(.vertical, verticalPadding)
            .frame(
                maxWidth: width ?? min(
                    UIScreen.main.bounds.width - 2 * AppTheme.Paddings.horizontal,
                    300
                )
            )
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
        }
        .buttonStyle(PlainButtonStyle()) // optional: remove default NavigationLink styling
    }
}
